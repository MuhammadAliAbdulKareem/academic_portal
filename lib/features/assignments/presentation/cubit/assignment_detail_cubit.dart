import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/assignment_repository.dart';
import 'assignment_detail_state.dart';

class AssignmentDetailCubit extends Cubit<AssignmentDetailState> {
  final AssignmentRepository repository;

  AssignmentDetailCubit({required this.repository}) : super(const AssignmentDetailInitial());

  Future<void> loadAssignmentDetails({
    required String assignmentId,
    String? studentId,
  }) async {
    emit(const AssignmentDetailLoading());
    try {
      final assignment = await repository.getAssignmentById(assignmentId);
      final studentSubmission = studentId != null
          ? await repository.getStudentSubmission(
              assignmentId: assignmentId,
              studentId: studentId,
            )
          : null;
      final allSubmissions = await repository.getSubmissionsForAssignment(assignmentId);

      emit(
        AssignmentDetailLoaded(
          assignment: assignment,
          studentSubmission: studentSubmission,
          allSubmissions: allSubmissions,
        ),
      );
    } catch (e) {
      emit(AssignmentDetailError('Failed to load assignment details: ${e.toString()}'));
    }
  }

  Future<void> refreshAssignmentDetails({
    required String assignmentId,
    String? studentId,
  }) async {
    try {
      final assignment = await repository.getAssignmentById(assignmentId);
      final studentSubmission = studentId != null
          ? await repository.getStudentSubmission(
              assignmentId: assignmentId,
              studentId: studentId,
            )
          : null;
      final allSubmissions = await repository.getSubmissionsForAssignment(assignmentId);

      emit(
        AssignmentDetailLoaded(
          assignment: assignment,
          studentSubmission: studentSubmission,
          allSubmissions: allSubmissions,
        ),
      );
    } catch (_) {
      // Keep current state on background refresh error
    }
  }
}
