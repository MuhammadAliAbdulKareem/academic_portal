import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class AttendanceRosterState extends Equatable {
  const AttendanceRosterState();

  @override
  List<Object?> get props => [];
}

class AttendanceRosterInitial extends AttendanceRosterState {
  const AttendanceRosterInitial();
}

class AttendanceRosterLoading extends AttendanceRosterState {
  const AttendanceRosterLoading();
}

class AttendanceRosterLoaded extends AttendanceRosterState {
  final List<AttendanceRecordEntity> allRecords;
  final List<AttendanceRecordEntity> filteredRecords;
  final AttendanceSessionEntity? session;
  final AttendanceStatus? statusFilter;
  final String searchQuery;

  const AttendanceRosterLoaded({
    required this.allRecords,
    required this.filteredRecords,
    this.session,
    this.statusFilter,
    this.searchQuery = '',
  });

  int get presentCount =>
      allRecords.where((r) => r.status == AttendanceStatus.present).length;
  int get lateCount =>
      allRecords.where((r) => r.status == AttendanceStatus.late).length;
  int get absentCount =>
      allRecords.where((r) => r.status == AttendanceStatus.absent).length;
  int get excusedCount =>
      allRecords.where((r) => r.status == AttendanceStatus.excused).length;

  AttendanceRosterLoaded copyWith({
    List<AttendanceRecordEntity>? allRecords,
    List<AttendanceRecordEntity>? filteredRecords,
    AttendanceSessionEntity? session,
    AttendanceStatus? statusFilter,
    bool clearStatusFilter = false,
    String? searchQuery,
  }) {
    return AttendanceRosterLoaded(
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      session: session ?? this.session,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        allRecords,
        filteredRecords,
        session,
        statusFilter,
        searchQuery,
      ];
}

class AttendanceRosterUpdating extends AttendanceRosterState {
  final String recordId;
  const AttendanceRosterUpdating(this.recordId);

  @override
  List<Object?> get props => [recordId];
}

class AttendanceRosterError extends AttendanceRosterState {
  final String message;
  const AttendanceRosterError(this.message);

  @override
  List<Object?> get props => [message];
}
