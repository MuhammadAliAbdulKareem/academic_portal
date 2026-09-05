import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/communications_repository.dart';
import 'announcements_state.dart';

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  final CommunicationsRepository repository;

  AnnouncementsCubit({required this.repository}) : super(const AnnouncementsInitial());

  Future<void> loadAnnouncements({String? courseId, String? studentId}) async {
    emit(const AnnouncementsLoading());
    try {
      final list = await repository.getAnnouncements(courseId: courseId, studentId: studentId);
      emit(AnnouncementsLoaded(announcements: list, selectedCourseId: courseId ?? 'all'));
    } catch (e) {
      emit(AnnouncementsError(e.toString()));
    }
  }

  void filterByCourse(String courseId) {
    if (state is AnnouncementsLoaded) {
      final current = state as AnnouncementsLoaded;
      emit(current.copyWith(selectedCourseId: courseId));
    }
  }

  void filterByPriority(AnnouncementPriority? priority) {
    if (state is AnnouncementsLoaded) {
      final current = state as AnnouncementsLoaded;
      emit(current.copyWith(selectedPriority: priority, clearPriority: priority == null));
    }
  }

  void setSearchQuery(String query) {
    if (state is AnnouncementsLoaded) {
      final current = state as AnnouncementsLoaded;
      emit(current.copyWith(searchQuery: query));
    }
  }

  Future<void> createAnnouncement(AnnouncementEntity announcement) async {
    try {
      await repository.createAnnouncement(announcement);
      // Reload announcements
      final list = await repository.getAnnouncements();
      if (state is AnnouncementsLoaded) {
        final current = state as AnnouncementsLoaded;
        emit(current.copyWith(announcements: list));
      } else {
        emit(AnnouncementsLoaded(announcements: list));
      }
    } catch (e) {
      emit(AnnouncementsError('Failed to create announcement: $e'));
    }
  }

  Future<void> markAsRead({required String announcementId, required String studentId}) async {
    try {
      await repository.markAnnouncementAsRead(announcementId: announcementId, studentId: studentId);
      if (state is AnnouncementsLoaded) {
        final current = state as AnnouncementsLoaded;
        final updated = current.announcements.map((a) {
          if (a.id == announcementId && !a.readByStudentIds.contains(studentId)) {
            final ids = List<String>.from(a.readByStudentIds)..add(studentId);
            return a.copyWith(readByStudentIds: ids);
          }
          return a;
        }).toList();
        emit(current.copyWith(announcements: updated));
      }
    } catch (e) {
      // Non-blocking error
    }
  }
}
