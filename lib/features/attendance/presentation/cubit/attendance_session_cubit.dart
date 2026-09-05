import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_session_state.dart';

class AttendanceSessionCubit extends Cubit<AttendanceSessionState> {
  final AttendanceRepository repository;

  AttendanceSessionCubit({required this.repository})
      : super(const AttendanceSessionInitial());

  Future<void> loadSessions(String courseId) async {
    emit(const AttendanceSessionLoading());
    try {
      final sessions = await repository.getCourseSessions(courseId);
      final active = await repository.getActiveSession(courseId);
      emit(
        AttendanceSessionLoaded(
          allSessions: sessions,
          filteredSessions: sessions,
          activeSession: active,
          selectedCourseId: courseId,
        ),
      );
    } catch (e) {
      emit(AttendanceSessionError('Failed to load sessions: ${e.toString()}'));
    }
  }

  Future<void> startNewSession({
    required String courseId,
    required String courseCode,
    required String courseTitle,
    required String section,
    required String title,
    required String room,
    int durationMinutes = 15,
  }) async {
    final currentLoaded = state is AttendanceSessionLoaded ? state as AttendanceSessionLoaded : null;
    emit(const AttendanceSessionActionInProgress('Generating QR token and opening session...'));
    try {
      final newSession = await repository.startAttendanceSession(
        courseId: courseId,
        courseCode: courseCode,
        courseTitle: courseTitle,
        section: section,
        title: title,
        room: room,
        durationMinutes: durationMinutes,
      );

      final allSessions = [
        newSession,
        if (currentLoaded != null)
          ...currentLoaded.allSessions.where((s) => s.id != newSession.id),
      ];

      emit(
        AttendanceSessionLoaded(
          allSessions: allSessions,
          filteredSessions: allSessions,
          activeSession: newSession,
          selectedCourseId: courseId,
        ),
      );
    } catch (e) {
      emit(AttendanceSessionError('Failed to start session: ${e.toString()}'));
    }
  }

  Future<void> endSession(String sessionId) async {
    if (state is! AttendanceSessionLoaded) return;
    final current = state as AttendanceSessionLoaded;

    emit(const AttendanceSessionActionInProgress('Closing check-in session...'));
    try {
      final ended = await repository.endAttendanceSession(sessionId);
      final updatedList = current.allSessions.map((s) {
        return s.id == sessionId ? ended : s;
      }).toList();

      emit(
        current.copyWith(
          allSessions: updatedList,
          filteredSessions: updatedList,
          clearActiveSession: true,
        ),
      );
    } catch (e) {
      emit(AttendanceSessionError('Failed to end session: ${e.toString()}'));
    }
  }

  void searchSessions(String query) {
    if (state is! AttendanceSessionLoaded) return;
    final current = state as AttendanceSessionLoaded;
    final trimmed = query.trim().toLowerCase();

    if (trimmed.isEmpty) {
      emit(current.copyWith(searchQuery: '', filteredSessions: current.allSessions));
      return;
    }

    final filtered = current.allSessions.where((s) {
      return s.title.toLowerCase().contains(trimmed) ||
          s.room.toLowerCase().contains(trimmed) ||
          s.section.toLowerCase().contains(trimmed);
    }).toList();

    emit(current.copyWith(searchQuery: query, filteredSessions: filtered));
  }

  void selectCourse(String courseId) {
    loadSessions(courseId);
  }
}
