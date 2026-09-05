import 'package:equatable/equatable.dart';
import '../../domain/entities/discussion_entity.dart';

abstract class DiscussionsState extends Equatable {
  const DiscussionsState();

  @override
  List<Object?> get props => [];
}

class DiscussionsInitial extends DiscussionsState {
  const DiscussionsInitial();
}

class DiscussionsLoading extends DiscussionsState {
  const DiscussionsLoading();
}

class DiscussionsLoaded extends DiscussionsState {
  final List<DiscussionThreadEntity> threads;
  final String selectedCourseId;
  final DiscussionCategory? selectedCategory;
  final String searchQuery;
  final bool onlyUnresolved;

  const DiscussionsLoaded({
    required this.threads,
    this.selectedCourseId = 'all',
    this.selectedCategory,
    this.searchQuery = '',
    this.onlyUnresolved = false,
  });

  List<DiscussionThreadEntity> get filteredThreads {
    var list = List<DiscussionThreadEntity>.from(threads);

    if (selectedCourseId != 'all' && selectedCourseId.isNotEmpty) {
      list = list
          .where((t) => t.courseId.toLowerCase() == selectedCourseId.toLowerCase())
          .toList();
    }

    if (selectedCategory != null) {
      list = list.where((t) => t.category == selectedCategory).toList();
    }

    if (onlyUnresolved) {
      list = list.where((t) => !t.isResolved).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.content.toLowerCase().contains(q) ||
            t.courseCode.toLowerCase().contains(q) ||
            t.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }

    return list;
  }

  DiscussionsLoaded copyWith({
    List<DiscussionThreadEntity>? threads,
    String? selectedCourseId,
    DiscussionCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    bool? onlyUnresolved,
  }) {
    return DiscussionsLoaded(
      threads: threads ?? this.threads,
      selectedCourseId: selectedCourseId ?? this.selectedCourseId,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      onlyUnresolved: onlyUnresolved ?? this.onlyUnresolved,
    );
  }

  @override
  List<Object?> get props => [
        threads,
        selectedCourseId,
        selectedCategory,
        searchQuery,
        onlyUnresolved,
      ];
}

class DiscussionsError extends DiscussionsState {
  final String message;

  const DiscussionsError(this.message);

  @override
  List<Object?> get props => [message];
}
