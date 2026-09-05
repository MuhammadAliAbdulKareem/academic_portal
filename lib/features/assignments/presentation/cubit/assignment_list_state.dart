import 'package:equatable/equatable.dart';
import '../../domain/entities/assignment_entity.dart';

abstract class AssignmentListState extends Equatable {
  const AssignmentListState();

  @override
  List<Object?> get props => [];
}

class AssignmentListInitial extends AssignmentListState {
  const AssignmentListInitial();
}

class AssignmentListLoading extends AssignmentListState {
  const AssignmentListLoading();
}

class AssignmentListLoaded extends AssignmentListState {
  final List<AssignmentEntity> allAssignments;
  final List<AssignmentEntity> filteredAssignments;
  final String searchQuery;
  final String? selectedCourseFilter;
  final String? selectedStatusFilter; // 'all', 'upcoming', 'open', 'closed'

  const AssignmentListLoaded({
    required this.allAssignments,
    required this.filteredAssignments,
    this.searchQuery = '',
    this.selectedCourseFilter,
    this.selectedStatusFilter,
  });

  AssignmentListLoaded copyWith({
    List<AssignmentEntity>? allAssignments,
    List<AssignmentEntity>? filteredAssignments,
    String? searchQuery,
    String? selectedCourseFilter,
    String? selectedStatusFilter,
  }) {
    return AssignmentListLoaded(
      allAssignments: allAssignments ?? this.allAssignments,
      filteredAssignments: filteredAssignments ?? this.filteredAssignments,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourseFilter: selectedCourseFilter ?? this.selectedCourseFilter,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
    );
  }

  @override
  List<Object?> get props => [
        allAssignments,
        filteredAssignments,
        searchQuery,
        selectedCourseFilter,
        selectedStatusFilter,
      ];
}

class AssignmentListError extends AssignmentListState {
  final String message;

  const AssignmentListError(this.message);

  @override
  List<Object?> get props => [message];
}
