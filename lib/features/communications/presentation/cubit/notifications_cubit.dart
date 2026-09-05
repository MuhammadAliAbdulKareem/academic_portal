import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/communications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final CommunicationsRepository repository;

  NotificationsCubit({required this.repository}) : super(const NotificationsInitial());

  Future<void> loadNotifications(String userId) async {
    emit(const NotificationsLoading());
    try {
      final list = await repository.getNotifications(userId);
      emit(NotificationsLoaded(notifications: list));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId, {required String userId}) async {
    try {
      await repository.markNotificationAsRead(notificationId);
      final list = await repository.getNotifications(userId);
      emit(NotificationsLoaded(notifications: list));
    } catch (e) {
      // Non-blocking
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await repository.markAllNotificationsAsRead(userId);
      final list = await repository.getNotifications(userId);
      emit(NotificationsLoaded(notifications: list));
    } catch (e) {
      // Non-blocking
    }
  }
}
