import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceSessionModel>> getCourseSessions(String courseId);
  Future<AttendanceSessionModel?> getActiveSession(String courseId);
  Future<AttendanceSessionModel> startAttendanceSession({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required String section,
    required String title,
    required String room,
    required int durationMinutes,
  });
  Future<AttendanceSessionModel> endAttendanceSession(String sessionId);
  Future<List<AttendanceRecordModel>> getSessionRecords(String sessionId);
  Future<AttendanceRecordModel> checkInStudent({
    required String sessionId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentAvatar,
    required CheckInMethod method,
    required String pinOrToken,
  });
  Future<AttendanceRecordModel> updateStudentRecordStatus({
    required String recordId,
    required AttendanceStatus newStatus,
    String? notes,
  });
  Future<List<AttendanceRecordModel>> getStudentAttendanceHistory({
    required String studentId,
    String? courseId,
  });
  Future<StudentAttendanceSummaryModel> getStudentAttendanceSummary({
    required String studentId,
    required String courseId,
  });
  Future<List<StudentAttendanceSummaryModel>> getAllStudentSummariesForCourse(
    String courseId,
  );
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore? _firestore;

  AttendanceRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get firestore => _firestore;

  // In-memory demo store initialized with realistic university attendance data
  static final List<AttendanceSessionModel> _mockSessions = [
    AttendanceSessionModel(
      id: 'session-cs101-14',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      courseTitle: 'Introduction to Computer Science',
      section: 'Section 01',
      title: 'Lecture 14: Dynamic Programming & Memoization',
      room: 'Turing Hall 302',
      startTime: DateTime.now().subtract(const Duration(minutes: 8)),
      endTime: DateTime.now().add(const Duration(minutes: 52)),
      qrToken: 'CS101-L14-8F3A29',
      sessionPin: '749210',
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      totalEnrolled: 30,
      presentCount: 22,
      lateCount: 3,
      absentCount: 5,
      excusedCount: 0,
    ),
    AttendanceSessionModel(
      id: 'session-cs101-13',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      courseTitle: 'Introduction to Computer Science',
      section: 'Section 01',
      title: 'Lecture 13: Binary Search Trees & AVL Trees',
      room: 'Turing Hall 302',
      startTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      endTime: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      qrToken: 'CS101-L13-A91B4C',
      sessionPin: '512934',
      isActive: false,
      expiresAt: DateTime.now().subtract(const Duration(days: 2, hours: 1, minutes: 45)),
      totalEnrolled: 30,
      presentCount: 26,
      lateCount: 2,
      absentCount: 1,
      excusedCount: 1,
    ),
    AttendanceSessionModel(
      id: 'session-cs201-06',
      courseId: 'course-cs201',
      courseCode: 'CS201',
      courseTitle: 'Data Structures & Algorithms',
      section: 'Section 02',
      title: 'Lab 06: Graph Shortest Path & Dijkstra',
      room: 'Ada Lovelace Lab 104',
      startTime: DateTime.now().subtract(const Duration(minutes: 10)),
      endTime: DateTime.now().add(const Duration(minutes: 80)),
      qrToken: 'CS201-L06-K92X11',
      sessionPin: '381045',
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(minutes: 20)),
      totalEnrolled: 25,
      presentCount: 18,
      lateCount: 2,
      absentCount: 4,
      excusedCount: 1,
    ),
    AttendanceSessionModel(
      id: 'session-math301-11',
      courseId: 'course-math301',
      courseCode: 'MATH301',
      courseTitle: 'Linear Algebra & Differential Equations',
      section: 'Section 01',
      title: 'Lecture 11: Eigenvalues and Spectral Decomposition',
      room: 'Euler Auditorium 101',
      startTime: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
      endTime: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      qrToken: 'MATH301-L11-P48D02',
      sessionPin: '694218',
      isActive: false,
      expiresAt: DateTime.now().subtract(const Duration(days: 3, hours: 2, minutes: 45)),
      totalEnrolled: 22,
      presentCount: 19,
      lateCount: 1,
      absentCount: 1,
      excusedCount: 1,
    ),
  ];

  static final List<AttendanceRecordModel> _mockRecords = [
    // CS101 Lecture 14 (Active)
    AttendanceRecordModel(
      id: 'rec-cs101-14-1',
      sessionId: 'session-cs101-14',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      sessionTitle: 'Lecture 14: Dynamic Programming & Memoization',
      studentId: 'user-student-1',
      studentName: 'Alex Rivera',
      studentEmail: 'student@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      status: AttendanceStatus.present,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 6)),
      checkInMethod: CheckInMethod.qrCode,
      notes: null,
    ),
    AttendanceRecordModel(
      id: 'rec-cs101-14-2',
      sessionId: 'session-cs101-14',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      sessionTitle: 'Lecture 14: Dynamic Programming & Memoization',
      studentId: 'user-student-2',
      studentName: 'Sarah Jenkins',
      studentEmail: 'sarah.j@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      status: AttendanceStatus.present,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 5)),
      checkInMethod: CheckInMethod.qrCode,
      notes: null,
    ),
    AttendanceRecordModel(
      id: 'rec-cs101-14-3',
      sessionId: 'session-cs101-14',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      sessionTitle: 'Lecture 14: Dynamic Programming & Memoization',
      studentId: 'user-student-3',
      studentName: 'Michael Chen',
      studentEmail: 'm.chen@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      status: AttendanceStatus.late,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 1)),
      checkInMethod: CheckInMethod.pinCode,
      notes: 'Bus delay reported',
    ),
    AttendanceRecordModel(
      id: 'rec-cs101-14-4',
      sessionId: 'session-cs101-14',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      sessionTitle: 'Lecture 14: Dynamic Programming & Memoization',
      studentId: 'user-student-4',
      studentName: 'Emma Watson',
      studentEmail: 'emma.w@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      status: AttendanceStatus.absent,
      checkInTime: null,
      checkInMethod: null,
      notes: null,
    ),
    AttendanceRecordModel(
      id: 'rec-cs101-14-5',
      sessionId: 'session-cs101-14',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      sessionTitle: 'Lecture 14: Dynamic Programming & Memoization',
      studentId: 'user-student-5',
      studentName: 'David Miller',
      studentEmail: 'david.m@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      status: AttendanceStatus.present,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 4)),
      checkInMethod: CheckInMethod.pinCode,
      notes: null,
    ),

    // CS101 Lecture 13 (Archived)
    AttendanceRecordModel(
      id: 'rec-cs101-13-1',
      sessionId: 'session-cs101-13',
      courseId: 'course-cs101',
      courseCode: 'CS101',
      sessionTitle: 'Lecture 13: Binary Search Trees & AVL Trees',
      studentId: 'user-student-1',
      studentName: 'Alex Rivera',
      studentEmail: 'student@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      status: AttendanceStatus.present,
      checkInTime: DateTime.now().subtract(const Duration(days: 2, hours: 1, minutes: 55)),
      checkInMethod: CheckInMethod.qrCode,
      notes: null,
    ),

    // CS201 Lab 06 (Active)
    AttendanceRecordModel(
      id: 'rec-cs201-06-1',
      sessionId: 'session-cs201-06',
      courseId: 'course-cs201',
      courseCode: 'CS201',
      sessionTitle: 'Lab 06: Graph Shortest Path & Dijkstra',
      studentId: 'user-student-1',
      studentName: 'Alex Rivera',
      studentEmail: 'student@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      status: AttendanceStatus.present,
      checkInTime: DateTime.now().subtract(const Duration(minutes: 8)),
      checkInMethod: CheckInMethod.qrCode,
      notes: null,
    ),

    // MATH301 Lecture 11 (Archived)
    AttendanceRecordModel(
      id: 'rec-math301-11-1',
      sessionId: 'session-math301-11',
      courseId: 'course-math301',
      courseCode: 'MATH301',
      sessionTitle: 'Lecture 11: Eigenvalues and Spectral Decomposition',
      studentId: 'user-student-1',
      studentName: 'Alex Rivera',
      studentEmail: 'student@academicportal.edu',
      studentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      status: AttendanceStatus.excused,
      checkInTime: null,
      checkInMethod: CheckInMethod.manualOverride,
      notes: 'Medical certificate approved by academic affairs',
    ),
  ];

  @override
  Future<List<AttendanceSessionModel>> getCourseSessions(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final sessions = _mockSessions.where((s) => s.courseId == courseId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  @override
  Future<AttendanceSessionModel?> getActiveSession(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final active = _mockSessions.where(
      (s) => s.courseId == courseId && s.isActive && !s.isExpired,
    );
    return active.isNotEmpty ? active.first : null;
  }

  @override
  Future<AttendanceSessionModel> startAttendanceSession({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required String section,
    required String title,
    required String room,
    required int durationMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // End any currently open session for this course first
    for (int i = 0; i < _mockSessions.length; i++) {
      if (_mockSessions[i].courseId == courseId && _mockSessions[i].isActive) {
        _mockSessions[i] = AttendanceSessionModel.fromEntity(
          _mockSessions[i].copyWith(isActive: false),
        );
      }
    }

    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: durationMinutes));
    final pin = (100000 + (now.millisecondsSinceEpoch % 900000)).toString();
    final qrToken = '$courseCode-S${_mockSessions.length + 1}-${now.millisecondsSinceEpoch.toRadixString(16).toUpperCase()}';
    final sessionId = 'session-${courseId.replaceAll('course-', '')}-${_mockSessions.length + 1}';

    final newSession = AttendanceSessionModel(
      id: sessionId,
      courseId: courseId,
      courseCode: courseCode,
      courseTitle: courseTitle,
      section: section,
      title: title,
      room: room,
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
      qrToken: qrToken,
      sessionPin: pin,
      isActive: true,
      expiresAt: expiresAt,
      totalEnrolled: 25,
      presentCount: 0,
      lateCount: 0,
      absentCount: 25,
      excusedCount: 0,
    );

    _mockSessions.insert(0, newSession);
    return newSession;
  }

  @override
  Future<AttendanceSessionModel> endAttendanceSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) {
      throw Exception('Attendance session not found: $sessionId');
    }

    final updated = _mockSessions[index].copyWith(
      isActive: false,
    );
    final model = AttendanceSessionModel.fromEntity(updated);
    _mockSessions[index] = model;
    return model;
  }

  @override
  Future<List<AttendanceRecordModel>> getSessionRecords(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockRecords.where((r) => r.sessionId == sessionId).toList();
  }

  @override
  Future<AttendanceRecordModel> checkInStudent({
    required String sessionId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentAvatar,
    required CheckInMethod method,
    required String pinOrToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final sessionIndex = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) {
      throw Exception('Attendance session not found.');
    }

    final session = _mockSessions[sessionIndex];
    if (!session.isActive) {
      throw Exception('This attendance check-in session is closed.');
    }

    if (DateTime.now().isAfter(session.expiresAt)) {
      throw Exception('This check-in session has expired.');
    }

    // Verify code: accept exact match of either QR token or 6-digit PIN
    final normalizedInput = pinOrToken.trim().toUpperCase();
    final validToken = session.qrToken.toUpperCase();
    final validPin = session.sessionPin;

    if (normalizedInput != validToken && normalizedInput != validPin) {
      throw Exception('Invalid QR code token or 6-digit session PIN.');
    }

    // Check if student already checked in
    final existingIndex = _mockRecords.indexWhere(
      (r) => r.sessionId == sessionId && r.studentId == studentId,
    );

    if (existingIndex != -1) {
      final existing = _mockRecords[existingIndex];
      if (existing.status == AttendanceStatus.present ||
          existing.status == AttendanceStatus.late) {
        throw Exception('You have already checked into this session.');
      }
    }

    final now = DateTime.now();
    // Mark as late if checked in more than 10 minutes after session start
    final isLate = now.difference(session.startTime).inMinutes > 10;
    final status = isLate ? AttendanceStatus.late : AttendanceStatus.present;

    final record = AttendanceRecordModel(
      id: existingIndex != -1
          ? _mockRecords[existingIndex].id
          : 'rec-$sessionId-$studentId',
      sessionId: sessionId,
      courseId: session.courseId,
      courseCode: session.courseCode,
      sessionTitle: session.title,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentAvatar: studentAvatar,
      status: status,
      checkInTime: now,
      checkInMethod: method,
      notes: isLate ? 'Late arrival recorded' : null,
    );

    if (existingIndex != -1) {
      _mockRecords[existingIndex] = record;
    } else {
      _mockRecords.add(record);
    }

    // Update session counts
    final newPresent = isLate ? session.presentCount : session.presentCount + 1;
    final newLate = isLate ? session.lateCount + 1 : session.lateCount;
    final newAbsent = session.absentCount > 0 ? session.absentCount - 1 : 0;

    _mockSessions[sessionIndex] = AttendanceSessionModel.fromEntity(
      session.copyWith(
        presentCount: newPresent,
        lateCount: newLate,
        absentCount: newAbsent,
      ),
    );

    return record;
  }

  @override
  Future<AttendanceRecordModel> updateStudentRecordStatus({
    required String recordId,
    required AttendanceStatus newStatus,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockRecords.indexWhere((r) => r.id == recordId);
    if (index == -1) {
      throw Exception('Attendance record not found: $recordId');
    }

    final oldRecord = _mockRecords[index];
    final updated = oldRecord.copyWith(
      status: newStatus,
      checkInMethod: CheckInMethod.manualOverride,
      notes: notes ?? oldRecord.notes,
      checkInTime: newStatus == AttendanceStatus.absent ? null : (oldRecord.checkInTime ?? DateTime.now()),
    );

    final model = AttendanceRecordModel.fromEntity(updated);
    _mockRecords[index] = model;

    // Recalculate session counters
    final sessionIndex = _mockSessions.indexWhere((s) => s.id == oldRecord.sessionId);
    if (sessionIndex != -1) {
      final sessionRecords = _mockRecords.where((r) => r.sessionId == oldRecord.sessionId).toList();
      int p = 0, l = 0, a = 0, e = 0;
      for (final r in sessionRecords) {
        switch (r.status) {
          case AttendanceStatus.present:
            p++;
            break;
          case AttendanceStatus.late:
            l++;
            break;
          case AttendanceStatus.absent:
            a++;
            break;
          case AttendanceStatus.excused:
            e++;
            break;
        }
      }
      _mockSessions[sessionIndex] = AttendanceSessionModel.fromEntity(
        _mockSessions[sessionIndex].copyWith(
          presentCount: p,
          lateCount: l,
          absentCount: a,
          excusedCount: e,
        ),
      );
    }

    return model;
  }

  @override
  Future<List<AttendanceRecordModel>> getStudentAttendanceHistory({
    required String studentId,
    String? courseId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    var records = _mockRecords.where((r) => r.studentId == studentId);
    if (courseId != null && courseId.isNotEmpty) {
      records = records.where((r) => r.courseId == courseId);
    }
    final list = records.toList()
      ..sort((a, b) => (b.checkInTime ?? DateTime(2000)).compareTo(a.checkInTime ?? DateTime(2000)));
    return list;
  }

  @override
  Future<StudentAttendanceSummaryModel> getStudentAttendanceSummary({
    required String studentId,
    required String courseId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final sessions = _mockSessions.where((s) => s.courseId == courseId).toList();
    final records = _mockRecords.where(
      (r) => r.studentId == studentId && r.courseId == courseId,
    ).toList();

    int p = 0, l = 0, a = 0, e = 0;
    for (final r in records) {
      switch (r.status) {
        case AttendanceStatus.present:
          p++;
          break;
        case AttendanceStatus.late:
          l++;
          break;
        case AttendanceStatus.absent:
          a++;
          break;
        case AttendanceStatus.excused:
          e++;
          break;
      }
    }

    final total = sessions.isNotEmpty ? sessions.length : records.length;
    // Unrecorded sessions count as absent
    if (records.length < total) {
      a += (total - records.length);
    }

    final course = sessions.isNotEmpty ? sessions.first : null;

    return StudentAttendanceSummaryModel(
      studentId: studentId,
      courseId: courseId,
      courseCode: course?.courseCode ?? 'COURSE',
      courseTitle: course?.courseTitle ?? 'Course Title',
      totalSessions: total,
      presentSessions: p,
      lateSessions: l,
      absentSessions: a,
      excusedSessions: e,
    );
  }

  @override
  Future<List<StudentAttendanceSummaryModel>> getAllStudentSummariesForCourse(
    String courseId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final studentIds = _mockRecords
        .where((r) => r.courseId == courseId)
        .map((r) => r.studentId)
        .toSet()
        .toList();

    if (studentIds.isEmpty) {
      studentIds.add('user-student-1');
    }

    final summaries = <StudentAttendanceSummaryModel>[];
    for (final sid in studentIds) {
      final summary = await getStudentAttendanceSummary(
        studentId: sid,
        courseId: courseId,
      );
      summaries.add(summary);
    }
    return summaries;
  }
}
