import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academic_portal/features/auth/domain/entities/user_entity.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:academic_portal/features/auth/presentation/cubit/auth_state.dart';
import 'package:academic_portal/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:academic_portal/features/attendance/data/models/attendance_model.dart';
import 'package:academic_portal/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:academic_portal/features/attendance/domain/entities/attendance_entity.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/attendance_roster_cubit.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/attendance_roster_state.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/attendance_session_cubit.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/attendance_session_state.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/student_attendance_history_cubit.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/student_attendance_history_state.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/student_check_in_cubit.dart';
import 'package:academic_portal/features/attendance/presentation/cubit/student_check_in_state.dart';
import 'package:academic_portal/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:academic_portal/features/attendance/presentation/widgets/attendance_record_tile.dart';
import 'package:academic_portal/features/attendance/presentation/widgets/attendance_stats_summary_card.dart';
import 'package:academic_portal/features/attendance/presentation/widgets/portal_qr_widget.dart';
import 'package:academic_portal/features/attendance/presentation/widgets/session_qr_display_card.dart';
import 'package:academic_portal/features/attendance/presentation/widgets/qr_scanner_dialog.dart';

class FakeStudentAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeStudentAuthCubit()
      : super(
          Authenticated(
            UserEntity(
              id: 'user-student-1',
              email: 'student@academicportal.edu',
              displayName: 'Alex Rivera',
              role: UserRole.student,
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Attendance & Check-In Unit Tests', () {
    test('AttendanceSessionModel and AttendanceRecordModel serialize and deserialize', () {
      final now = DateTime(2026, 9, 5, 10, 0);
      final expires = DateTime(2026, 9, 5, 10, 15);

      final session = AttendanceSessionModel(
        id: 's-01',
        courseId: 'c-01',
        courseCode: 'CS101',
        courseTitle: 'Intro CS',
        section: 'Sec 1',
        title: 'Lecture 1',
        room: 'Room 101',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        qrToken: 'TOKEN-123',
        sessionPin: '123456',
        isActive: true,
        expiresAt: expires,
        totalEnrolled: 30,
        presentCount: 20,
        lateCount: 5,
        absentCount: 5,
        excusedCount: 0,
      );

      final sessionJson = session.toJson();
      expect(sessionJson['qrToken'], equals('TOKEN-123'));
      expect(sessionJson['sessionPin'], equals('123456'));

      final fromJson = AttendanceSessionModel.fromJson(sessionJson);
      expect(fromJson.id, equals('s-01'));
      expect(fromJson.attendedCount, equals(25));
      expect(fromJson.attendanceRate, closeTo(83.33, 0.1));

      final record = AttendanceRecordModel(
        id: 'r-01',
        sessionId: 's-01',
        courseId: 'c-01',
        courseCode: 'CS101',
        sessionTitle: 'Lecture 1',
        studentId: 'st-01',
        studentName: 'Alex Rivera',
        studentEmail: 'student@edu',
        status: AttendanceStatus.present,
        checkInTime: now,
        checkInMethod: CheckInMethod.qrCode,
      );

      final recordJson = record.toJson();
      expect(recordJson['status'], equals('present'));
      expect(recordJson['checkInMethod'], equals('qrCode'));

      final recordFromJson = AttendanceRecordModel.fromJson(recordJson);
      expect(recordFromJson.studentName, equals('Alex Rivera'));
      expect(recordFromJson.status, equals(AttendanceStatus.present));
    });

    test('StudentAttendanceSummaryEntity calculates rate and at-risk flag correctly', () {
      const summaryGood = StudentAttendanceSummaryEntity(
        studentId: 'st-01',
        courseId: 'c-01',
        courseCode: 'CS101',
        courseTitle: 'Intro CS',
        totalSessions: 10,
        presentSessions: 8,
        lateSessions: 1,
        absentSessions: 1,
        excusedSessions: 0,
      );

      expect(summaryGood.attendedSessions, equals(9));
      expect(summaryGood.attendanceRate, equals(90.0));
      expect(summaryGood.isAtRisk, isFalse);

      const summaryRisk = StudentAttendanceSummaryEntity(
        studentId: 'st-02',
        courseId: 'c-01',
        courseCode: 'CS101',
        courseTitle: 'Intro CS',
        totalSessions: 10,
        presentSessions: 5,
        lateSessions: 1,
        absentSessions: 4,
        excusedSessions: 0,
      );

      expect(summaryRisk.attendedSessions, equals(6));
      expect(summaryRisk.attendanceRate, equals(60.0));
      expect(summaryRisk.isAtRisk, isTrue);
    });

    test('AttendanceSessionCubit loads, creates, ends, and searches sessions', () async {
      final repo = AttendanceRepositoryImpl(
        remoteDataSource: AttendanceRemoteDataSourceImpl(),
      );
      final cubit = AttendanceSessionCubit(repository: repo);

      await cubit.loadSessions('course-cs101');
      expect(cubit.state, isA<AttendanceSessionLoaded>());
      final loaded = cubit.state as AttendanceSessionLoaded;
      expect(loaded.allSessions.isNotEmpty, isTrue);

      // Search sessions
      cubit.searchSessions('Dynamic');
      final searchState = cubit.state as AttendanceSessionLoaded;
      expect(searchState.filteredSessions.length, equals(1));

      // Reset search
      cubit.searchSessions('');

      // Start new session
      await cubit.startNewSession(
        courseId: 'course-cs101',
        courseCode: 'CS101',
        courseTitle: 'Intro CS',
        section: 'Section 01',
        title: 'New Unit Test Session',
        room: 'Test Hall A',
      );
      final withNew = cubit.state as AttendanceSessionLoaded;
      expect(withNew.activeSession?.title, equals('New Unit Test Session'));

      // End session
      final newId = withNew.activeSession!.id;
      await cubit.endSession(newId);
      final endedState = cubit.state as AttendanceSessionLoaded;
      expect(endedState.activeSession, isNull);

      await cubit.close();
    });

    test('AttendanceRosterCubit loads records, filters by status, and updates record', () async {
      final repo = AttendanceRepositoryImpl(
        remoteDataSource: AttendanceRemoteDataSourceImpl(),
      );
      final cubit = AttendanceRosterCubit(repository: repo);

      await cubit.loadRoster('session-cs101-14');
      expect(cubit.state, isA<AttendanceRosterLoaded>());
      final loaded = cubit.state as AttendanceRosterLoaded;
      expect(loaded.allRecords.isNotEmpty, isTrue);

      // Filter by Present
      cubit.filterByStatus(AttendanceStatus.present);
      var filteredState = cubit.state as AttendanceRosterLoaded;
      for (final r in filteredState.filteredRecords) {
        expect(r.status, equals(AttendanceStatus.present));
      }

      // Update student status to late
      final firstId = loaded.allRecords.first.id;
      await cubit.updateStatus(
        recordId: firstId,
        newStatus: AttendanceStatus.late,
        notes: 'Verified bus delay',
      );

      final updatedState = cubit.state as AttendanceRosterLoaded;
      final updatedRec = updatedState.allRecords.firstWhere((r) => r.id == firstId);
      expect(updatedRec.status, equals(AttendanceStatus.late));
      expect(updatedRec.notes, equals('Verified bus delay'));

      await cubit.close();
    });

    test('StudentCheckInCubit rejects empty input and accepts valid PIN', () async {
      final repo = AttendanceRepositoryImpl(
        remoteDataSource: AttendanceRemoteDataSourceImpl(),
      );
      final cubit = StudentCheckInCubit(repository: repo);

      final testSession = await repo.startAttendanceSession(
        courseId: 'course-test-checkin',
        courseCode: 'CS101',
        courseTitle: 'Intro CS',
        section: 'Section 01',
        title: 'Check-in Unit Test Lecture',
        room: 'Hall 101',
        durationMinutes: 30,
      );

      // Empty PIN rejection
      await cubit.submitCheckIn(
        sessionId: testSession.id,
        studentId: 'test-student-unique',
        studentName: 'New Student',
        studentEmail: 'new@edu',
        method: CheckInMethod.pinCode,
        pinOrToken: '',
      );
      expect(cubit.state, isA<StudentCheckInFailure>());

      // Valid session PIN submission
      await cubit.submitCheckIn(
        sessionId: testSession.id,
        studentId: 'test-student-unique',
        studentName: 'New Student',
        studentEmail: 'new@edu',
        method: CheckInMethod.pinCode,
        pinOrToken: testSession.sessionPin,
      );
      expect(cubit.state, isA<StudentCheckInSuccess>());
      final success = cubit.state as StudentCheckInSuccess;
      expect(success.record.studentId, equals('test-student-unique'));

      // Duplicate check in should fail
      await cubit.submitCheckIn(
        sessionId: testSession.id,
        studentId: 'test-student-unique',
        studentName: 'New Student',
        studentEmail: 'new@edu',
        method: CheckInMethod.pinCode,
        pinOrToken: testSession.sessionPin,
      );
      expect(cubit.state, isA<StudentCheckInFailure>());

      await cubit.close();
    });

    test('StudentAttendanceHistoryCubit loads history and computes rate', () async {
      final repo = AttendanceRepositoryImpl(
        remoteDataSource: AttendanceRemoteDataSourceImpl(),
      );
      final cubit = StudentAttendanceHistoryCubit(repository: repo);

      await cubit.loadHistory(studentId: 'user-student-1');
      expect(cubit.state, isA<StudentAttendanceHistoryLoaded>());
      final loaded = cubit.state as StudentAttendanceHistoryLoaded;
      expect(loaded.allRecords.isNotEmpty, isTrue);
      expect(loaded.courseSummaries.isNotEmpty, isTrue);
      expect(loaded.overallAttendanceRate, greaterThan(50.0));

      await cubit.close();
    });
  });

  group('Attendance & Check-In Widget Tests', () {
    testWidgets('PortalQrWidget renders canvas and central school icon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PortalQrWidget(
                data: 'CS101-TOKEN-XYZ',
                size: 180,
                showExpiryRing: false,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PortalQrWidget), findsOneWidget);
      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
    });

    testWidgets('SessionQrDisplayCard renders title, PIN, and attendee turnout',
        (tester) async {
      final session = AttendanceSessionEntity(
        id: 'sess-card-01',
        courseId: 'c-01',
        courseCode: 'CS101',
        courseTitle: 'Introduction to CS',
        section: 'Section 01',
        title: 'Lecture 14: Dynamic Programming',
        room: 'Turing Hall 302',
        startTime: DateTime.now().subtract(const Duration(minutes: 5)),
        endTime: DateTime.now().add(const Duration(minutes: 55)),
        qrToken: 'QR-DEMO-TOKEN',
        sessionPin: '749210',
        isActive: true,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        totalEnrolled: 30,
        presentCount: 22,
        lateCount: 3,
        absentCount: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionQrDisplayCard(session: session),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('LIVE CHECK-IN OPEN'), findsOneWidget);
      expect(find.text('Lecture 14: Dynamic Programming'), findsOneWidget);
      expect(find.text('749210'), findsOneWidget);
      expect(find.textContaining('Live Turnout: 25 of 30'), findsOneWidget);
    });

    testWidgets('AttendanceRecordTile renders student info and status pill',
        (tester) async {
      const record = AttendanceRecordEntity(
        id: 'rec-tile-01',
        sessionId: 'sess-01',
        courseId: 'c-01',
        courseCode: 'CS101',
        sessionTitle: 'Lecture 14',
        studentId: 'st-01',
        studentName: 'Alex Rivera',
        studentEmail: 'student@academicportal.edu',
        status: AttendanceStatus.present,
        checkInMethod: CheckInMethod.qrCode,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AttendanceRecordTile(record: record),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Alex Rivera'), findsOneWidget);
      expect(find.text('student@academicportal.edu'), findsOneWidget);
      expect(find.text('Present'), findsOneWidget);
      expect(find.text('QR Code Scan'), findsOneWidget);
    });

    testWidgets('AttendanceStatsSummaryCard renders course code, title, and rate',
        (tester) async {
      const summary = StudentAttendanceSummaryEntity(
        studentId: 'st-01',
        courseId: 'c-01',
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        totalSessions: 14,
        presentSessions: 12,
        lateSessions: 1,
        absentSessions: 1,
        excusedSessions: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AttendanceStatsSummaryCard(summary: summary),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('CS101'), findsOneWidget);
      expect(find.text('Introduction to Computer Science'), findsOneWidget);
      expect(find.textContaining('92.9%'), findsOneWidget);
      expect(find.text('Present'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('AttendanceScreen renders student attendance hub and course rates',
        (tester) async {
      final repo = AttendanceRepositoryImpl(
        remoteDataSource: AttendanceRemoteDataSourceImpl(),
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => FakeStudentAuthCubit()),
            BlocProvider<AttendanceSessionCubit>(
              create: (_) => AttendanceSessionCubit(repository: repo),
            ),
            BlocProvider<StudentAttendanceHistoryCubit>(
              create: (_) => StudentAttendanceHistoryCubit(repository: repo),
            ),
            BlocProvider<StudentCheckInCubit>(
              create: (_) => StudentCheckInCubit(repository: repo),
            ),
          ],
          child: const MaterialApp(
            home: AttendanceScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Attendance & Check-In'), findsOneWidget);
      expect(find.text('Course Attendance Rates'), findsOneWidget);
      expect(find.text('My Attendance Journal'), findsOneWidget);
    });

    testWidgets('QrScannerDialog renders QR and PIN tabs with TickerProviderStateMixin cleanly',
        (tester) async {
      final repo = AttendanceRepositoryImpl(
        remoteDataSource: AttendanceRemoteDataSourceImpl(),
      );

      final session = AttendanceSessionModel(
        id: 's-01',
        courseId: 'c-01',
        courseCode: 'CS101',
        courseTitle: 'Introduction to Computer Science',
        section: 'Section 1',
        title: 'Lecture 1: Intro',
        room: 'Hall A',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        qrToken: 'TOKEN-TEST',
        sessionPin: '654321',
        isActive: true,
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
        totalEnrolled: 25,
        presentCount: 10,
        lateCount: 2,
        absentCount: 13,
        excusedCount: 0,
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<StudentCheckInCubit>(
              create: (_) => StudentCheckInCubit(repository: repo),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<StudentCheckInCubit>(),
                        child: QrScannerDialog(
                          session: session,
                          studentId: 'st-01',
                          studentName: 'Alex Rivera',
                          studentEmail: 'student@edu',
                        ),
                      ),
                    );
                  },
                  child: const Text('Open QR Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open QR Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Class Check-In'), findsOneWidget);
      expect(find.text('Camera Scan'), findsOneWidget);
      expect(find.text('6-Digit PIN'), findsOneWidget);

      expect(find.text('Simulate Instant QR Scan'), findsOneWidget);

      // Switch to PIN tab
      await tester.tap(find.text('6-Digit PIN'));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.textContaining('6-digit session PIN'), findsOneWidget);
    });
  });
}

