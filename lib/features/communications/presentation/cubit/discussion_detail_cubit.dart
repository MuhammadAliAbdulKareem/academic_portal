import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/discussion_entity.dart';
import '../../domain/repositories/communications_repository.dart';
import 'discussion_detail_state.dart';

class DiscussionDetailCubit extends Cubit<DiscussionDetailState> {
  final CommunicationsRepository repository;

  DiscussionDetailCubit({required this.repository}) : super(const DiscussionDetailInitial());

  Future<void> loadThread(String threadId) async {
    emit(const DiscussionDetailLoading());
    try {
      final thread = await repository.getDiscussionThreadById(threadId);
      emit(DiscussionDetailLoaded(thread: thread));
    } catch (e) {
      emit(DiscussionDetailError(e.toString()));
    }
  }

  Future<void> addReply({
    required String threadId,
    required DiscussionReplyEntity reply,
  }) async {
    if (state is! DiscussionDetailLoaded) return;
    final current = state as DiscussionDetailLoaded;
    emit(current.copyWith(isPostingReply: true));

    try {
      await repository.addDiscussionReply(threadId: threadId, reply: reply);
      final updatedThread = await repository.getDiscussionThreadById(threadId);
      emit(DiscussionDetailLoaded(thread: updatedThread, isPostingReply: false));
    } catch (e) {
      emit(current.copyWith(isPostingReply: false));
    }
  }

  Future<void> toggleUpvote({
    required String threadId,
    required String replyId,
    required String userId,
  }) async {
    if (state is! DiscussionDetailLoaded) return;
    try {
      await repository.toggleReplyUpvote(
        threadId: threadId,
        replyId: replyId,
        userId: userId,
      );
      final updatedThread = await repository.getDiscussionThreadById(threadId);
      emit(DiscussionDetailLoaded(thread: updatedThread));
    } catch (e) {
      // Non-blocking error
    }
  }

  Future<void> toggleInstructorEndorsement({
    required String threadId,
    required String replyId,
  }) async {
    if (state is! DiscussionDetailLoaded) return;
    try {
      await repository.toggleInstructorEndorsement(
        threadId: threadId,
        replyId: replyId,
      );
      final updatedThread = await repository.getDiscussionThreadById(threadId);
      emit(DiscussionDetailLoaded(thread: updatedThread));
    } catch (e) {
      // Non-blocking error
    }
  }
}
