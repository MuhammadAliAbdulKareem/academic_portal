import 'package:equatable/equatable.dart';
import '../../domain/entities/announcement_entity.dart';

abstract class AnnouncementsState extends Equatable {
  const AnnouncementsState();

  @override
  List<Object?> get props => [];
}

class AnnouncementsInitial extends AnnouncementsState {
  const AnnouncementsInitial();
}

class AnnouncementsLoading extends AnnouncementsState {
  const AnnouncementsLoading();
}

class AnnouncementsLoaded extends AnnouncementsState {
  final List<AnnouncementEntity> announcements;
  final String selectedCourseId;
  final AnnouncementPriority? selectedPriority;
  final String searchQuery;

  const AnnouncementsLoaded({
    required this.announcements,
    this.selectedCourseId = 'all',
    this.selectedPriority,
    this.searchQuery = '',
  });

  List<AnnouncementEntity> get filteredAnnouncements {
    var list = List<AnnouncementEntity>.from(announcements);

    if (selectedCourseId != 'all' && selectedCourseId.isNotEmpty) {
      list = list.where((a) => a.courseId == 'all' || a.courseId.toLowerCase() == selectedCourseId.toLowerCase()).toList();
    }

    if (selectedPriority != null) {
      list = list.where((a) => a.priority == selectedPriority).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      list = list.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.content.toLowerCase().contains(q) ||
            a.courseCode.toLowerCase().contains(q) ||
            a.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    return list;
  }

  int unreadCount(String studentId) {
    return announcements.where((a) => !a.isReadBy(studentId)).length;
  }

  AnnouncementsLoaded copyWith({
    List<AnnouncementEntity>? announcements,
    String? selectedCourseId,
    AnnouncementPriority? selectedPriority,
    bool clearPriority = false,
    String? searchQuery,
  }) {
    return AnnouncementsLoaded(
      announcements: announcements ?? this.announcements,
      selectedCourseId: selectedCourseId ?? this.selectedCourseId,
      selectedPriority: clearPriority ? null : (selectedPriority ?? this.selectedPriority),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        announcements,
        selectedCourseId,
        selectedPriority,
        searchQuery,
      ];
}

class AnnouncementsError extends AnnouncementsState {
  final String message;

  const AnnouncementsError(this.message);

  @override
  List<Object?> get props => [message];
}
