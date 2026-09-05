import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/assignment_repository.dart';
import 'gradebook_state.dart';

class GradebookCubit extends Cubit<GradebookState> {
  final AssignmentRepository repository;

  GradebookCubit({required this.repository}) : super(const GradebookInitial());

  Future<void> loadGradebook(String courseId) async {
    emit(const GradebookLoading());
    try {
      final gradebook = await repository.getCourseGradebook(courseId);
      emit(GradebookLoaded(gradebook));
    } catch (e) {
      emit(GradebookError('Failed to load course gradebook: ${e.toString()}'));
    }
  }
}
