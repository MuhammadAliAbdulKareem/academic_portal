import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/discussion_entity.dart';
import '../../domain/repositories/communications_repository.dart';
import 'discussions_state.dart';

class DiscussionsCubit extends Cubit<DiscussionsState> {
  final CommunicationsRepository repository;

  DiscussionsCubit({required this.repository}) : super(const DiscussionsInitial());

  Future<void> loadDiscussions({
    String? courseId,
    DiscussionCategory? category,
    String? searchQuery,
  }) async {
    emit(const DiscussionsLoading());
    try {
      final list = await repository.getDiscussionThreads(
        courseId: courseId,
        category: category,
        searchQuery: searchQuery,
      );
      emit(DiscussionsLoaded(
        threads: list,
        selectedCourseId: courseId ?? 'all',
        selectedCategory: category,
        searchQuery: searchQuery ?? '',
      ));
    } catch (e) {
      emit(DiscussionsError(e.toString()));
    }
  }

  void filterByCourse(String courseId) {
    if (state is DiscussionsLoaded) {
      final current = state as DiscussionsLoaded;
      emit(current.copyWith(selectedCourseId: courseId));
    }
  }

  void filterByCategory(DiscussionCategory? category) {
    if (state is DiscussionsLoaded) {
      final current = state as DiscussionsLoaded;
      emit(current.copyWith(selectedCategory: category, clearCategory: category == null));
    }
  }

  void toggleUnresolvedOnly() {
    if (state is DiscussionsLoaded) {
      final current = state as DiscussionsLoaded;
      emit(current.copyWith(onlyUnresolved: !current.onlyUnresolved));
    }
  }

  void setSearchQuery(String query) {
    if (state is DiscussionsLoaded) {
      final current = state as DiscussionsLoaded;
      emit(current.copyWith(searchQuery: query));
    }
  }

  Future<void> createThread(DiscussionThreadEntity thread) async {
    try {
      await repository.createDiscussionThread(thread);
      final list = await repository.getDiscussionThreads();
      if (state is DiscussionsLoaded) {
        final current = state as DiscussionsLoaded;
        emit(current.copyWith(threads: list));
      } else {
        emit(DiscussionsLoaded(threads: list));
      }
    } catch (e) {
      emit(DiscussionsError('Failed to create thread: $e'));
    }
  }
}
