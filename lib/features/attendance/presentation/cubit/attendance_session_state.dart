import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class AttendanceSessionState extends Equatable {
  const AttendanceSessionState();

  @override
  List<Object?> get props => [];
}

class AttendanceSessionInitial extends AttendanceSessionState {
  const AttendanceSessionInitial();
}

class AttendanceSessionLoading extends AttendanceSessionState {
  const AttendanceSessionLoading();
}

class AttendanceSessionLoaded extends AttendanceSessionState {
  final List<AttendanceSessionEntity> allSessions;
  final List<AttendanceSessionEntity> filteredSessions;
  final AttendanceSessionEntity? activeSession;
  final String selectedCourseId;
  final String searchQuery;

  const AttendanceSessionLoaded({
    required this.allSessions,
    required this.filteredSessions,
    this.activeSession,
    this.selectedCourseId = 'course-cs101',
    this.searchQuery = '',
  });

  AttendanceSessionLoaded copyWith({
    List<AttendanceSessionEntity>? allSessions,
    List<AttendanceSessionEntity>? filteredSessions,
    AttendanceSessionEntity? activeSession,
    bool clearActiveSession = false,
    String? selectedCourseId,
    String? searchQuery,
  }) {
    return AttendanceSessionLoaded(
      allSessions: allSessions ?? this.allSessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      activeSession:
          clearActiveSession ? null : (activeSession ?? this.activeSession),
      selectedCourseId: selectedCourseId ?? this.selectedCourseId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        allSessions,
        filteredSessions,
        activeSession,
        selectedCourseId,
        searchQuery,
      ];
}

class AttendanceSessionActionInProgress extends AttendanceSessionState {
  final String message;
  const AttendanceSessionActionInProgress(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceSessionError extends AttendanceSessionState {
  final String message;
  const AttendanceSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
