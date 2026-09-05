import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/assignment_repository.dart';
import 'assignment_list_state.dart';

class AssignmentListCubit extends Cubit<AssignmentListState> {
  final AssignmentRepository repository;

  AssignmentListCubit({required this.repository}) : super(const AssignmentListInitial());

  Future<void> loadAssignmentsForStudent(String studentId) async {
    emit(const AssignmentListLoading());
    try {
      final assignments = await repository.getAssignmentsForStudent(studentId);
      emit(
        AssignmentListLoaded(
          allAssignments: assignments,
          filteredAssignments: assignments,
        ),
      );
    } catch (e) {
      emit(AssignmentListError('Failed to load assignments: ${e.toString()}'));
    }
  }

  Future<void> loadAssignmentsForCourse(String courseId) async {
    emit(const AssignmentListLoading());
    try {
      final assignments = await repository.getAssignmentsForCourse(courseId);
      emit(
        AssignmentListLoaded(
          allAssignments: assignments,
          filteredAssignments: assignments,
          selectedCourseFilter: courseId,
        ),
      );
    } catch (e) {
      emit(AssignmentListError('Failed to load course assignments: ${e.toString()}'));
    }
  }

  void searchAssignments(String query) {
    if (state is! AssignmentListLoaded) return;
    final current = state as AssignmentListLoaded;
    final trimmed = query.trim().toLowerCase();

    final filtered = _applyFilters(
      current.allAssignments,
      searchQuery: trimmed,
      courseFilter: current.selectedCourseFilter,
      statusFilter: current.selectedStatusFilter,
    );

    emit(current.copyWith(searchQuery: query, filteredAssignments: filtered));
  }

  void filterByCourse(String? courseCode) {
    if (state is! AssignmentListLoaded) return;
    final current = state as AssignmentListLoaded;

    final filtered = _applyFilters(
      current.allAssignments,
      searchQuery: current.searchQuery.toLowerCase(),
      courseFilter: courseCode,
      statusFilter: current.selectedStatusFilter,
    );

    emit(current.copyWith(selectedCourseFilter: courseCode, filteredAssignments: filtered));
  }

  void filterByStatus(String? status) {
    if (state is! AssignmentListLoaded) return;
    final current = state as AssignmentListLoaded;

    final filtered = _applyFilters(
      current.allAssignments,
      searchQuery: current.searchQuery.toLowerCase(),
      courseFilter: current.selectedCourseFilter,
      statusFilter: status,
    );

    emit(current.copyWith(selectedStatusFilter: status, filteredAssignments: filtered));
  }

  Future<void> createAssignment(AssignmentEntity assignment) async {
    try {
      final created = await repository.createAssignment(assignment);
      if (state is AssignmentListLoaded) {
        final current = state as AssignmentListLoaded;
        final updatedList = [created, ...current.allAssignments];
        final filtered = _applyFilters(
          updatedList,
          searchQuery: current.searchQuery.toLowerCase(),
          courseFilter: current.selectedCourseFilter,
          statusFilter: current.selectedStatusFilter,
        );
        emit(current.copyWith(allAssignments: updatedList, filteredAssignments: filtered));
      } else {
        emit(AssignmentListLoaded(allAssignments: [created], filteredAssignments: [created]));
      }
    } catch (e) {
      emit(AssignmentListError('Failed to create assignment: ${e.toString()}'));
    }
  }

  List<AssignmentEntity> _applyFilters(
    List<AssignmentEntity> source, {
    required String searchQuery,
    String? courseFilter,
    String? statusFilter,
  }) {
    return source.where((a) {
      final matchesSearch = searchQuery.isEmpty ||
          a.title.toLowerCase().contains(searchQuery) ||
          a.courseCode.toLowerCase().contains(searchQuery) ||
          a.description.toLowerCase().contains(searchQuery);

      final matchesCourse = courseFilter == null ||
          courseFilter == 'All' ||
          a.courseCode.toLowerCase() == courseFilter.toLowerCase() ||
          a.courseId == courseFilter;

      final matchesStatus = statusFilter == null ||
          statusFilter == 'All' ||
          (statusFilter == 'Upcoming' && a.status == AssignmentStatus.upcoming) ||
          (statusFilter == 'Open' && a.status == AssignmentStatus.open) ||
          (statusFilter == 'Closed' && a.status == AssignmentStatus.closed);

      return matchesSearch && matchesCourse && matchesStatus;
    }).toList();
  }
}
