import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'attendance_roster_state.dart';

class AttendanceRosterCubit extends Cubit<AttendanceRosterState> {
  final AttendanceRepository repository;

  AttendanceRosterCubit({required this.repository})
      : super(const AttendanceRosterInitial());

  Future<void> loadRoster(String sessionId, [AttendanceSessionEntity? session]) async {
    emit(const AttendanceRosterLoading());
    try {
      final records = await repository.getSessionRecords(sessionId);
      emit(
        AttendanceRosterLoaded(
          allRecords: records,
          filteredRecords: records,
          session: session,
        ),
      );
    } catch (e) {
      emit(AttendanceRosterError('Failed to load session roster: ${e.toString()}'));
    }
  }

  Future<void> updateStatus({
    required String recordId,
    required AttendanceStatus newStatus,
    String? notes,
  }) async {
    if (state is! AttendanceRosterLoaded) return;
    final current = state as AttendanceRosterLoaded;

    try {
      final updated = await repository.updateStudentRecordStatus(
        recordId: recordId,
        newStatus: newStatus,
        notes: notes,
      );

      final updatedAll = current.allRecords.map((r) {
        return r.id == recordId ? updated : r;
      }).toList();

      final filtered = _applyFilters(
        updatedAll,
        statusFilter: current.statusFilter,
        query: current.searchQuery,
      );

      emit(
        current.copyWith(
          allRecords: updatedAll,
          filteredRecords: filtered,
        ),
      );
    } catch (e) {
      emit(AttendanceRosterError('Failed to update attendance: ${e.toString()}'));
    }
  }

  void filterByStatus(AttendanceStatus? status) {
    if (state is! AttendanceRosterLoaded) return;
    final current = state as AttendanceRosterLoaded;

    final filtered = _applyFilters(
      current.allRecords,
      statusFilter: status,
      query: current.searchQuery,
    );

    emit(
      current.copyWith(
        statusFilter: status,
        clearStatusFilter: status == null,
        filteredRecords: filtered,
      ),
    );
  }

  void search(String query) {
    if (state is! AttendanceRosterLoaded) return;
    final current = state as AttendanceRosterLoaded;

    final filtered = _applyFilters(
      current.allRecords,
      statusFilter: current.statusFilter,
      query: query,
    );

    emit(current.copyWith(searchQuery: query, filteredRecords: filtered));
  }

  List<AttendanceRecordEntity> _applyFilters(
    List<AttendanceRecordEntity> records, {
    AttendanceStatus? statusFilter,
    String query = '',
  }) {
    var result = records;
    if (statusFilter != null) {
      result = result.where((r) => r.status == statusFilter).toList();
    }
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where((r) {
        return r.studentName.toLowerCase().contains(trimmed) ||
            r.studentEmail.toLowerCase().contains(trimmed);
      }).toList();
    }
    return result;
  }
}
