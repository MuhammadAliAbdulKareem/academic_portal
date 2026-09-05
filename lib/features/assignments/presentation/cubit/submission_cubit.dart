import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/assignment_repository.dart';
import 'submission_state.dart';

class SubmissionCubit extends Cubit<SubmissionState> {
  final AssignmentRepository repository;

  SubmissionCubit({required this.repository}) : super(const SubmissionInitial());

  void reset() {
    emit(const SubmissionInitial());
  }

  Future<void> submitWork({
    required String assignmentId,
    required String assignmentTitle,
    required String courseCode,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentAvatar,
    String? fileName,
    int? fileSizeBytes,
    String? textResponse,
  }) async {
    if ((fileName == null || fileName.trim().isEmpty) &&
        (textResponse == null || textResponse.trim().isEmpty)) {
      emit(const SubmissionFailure('Please attach a file or type a response.'));
      return;
    }

    emit(const SubmissionSubmitting(progress: 0.3));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      emit(const SubmissionSubmitting(progress: 0.8));

      final submission = SubmissionEntity(
        id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
        assignmentId: assignmentId,
        assignmentTitle: assignmentTitle,
        courseCode: courseCode,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        studentAvatar: studentAvatar,
        submittedAt: DateTime.now(),
        fileName: fileName,
        fileSizeBytes: fileSizeBytes ?? (fileName != null ? 1048576 : null),
        textResponse: textResponse,
        status: SubmissionStatus.submitted,
      );

      final saved = await repository.submitAssignment(submission);
      emit(SubmissionSuccess(saved));
    } catch (e) {
      emit(SubmissionFailure('Submission failed: ${e.toString()}'));
    }
  }
}
