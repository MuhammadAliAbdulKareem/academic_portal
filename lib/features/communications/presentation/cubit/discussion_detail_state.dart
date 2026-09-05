import 'package:equatable/equatable.dart';
import '../../domain/entities/discussion_entity.dart';

abstract class DiscussionDetailState extends Equatable {
  const DiscussionDetailState();

  @override
  List<Object?> get props => [];
}

class DiscussionDetailInitial extends DiscussionDetailState {
  const DiscussionDetailInitial();
}

class DiscussionDetailLoading extends DiscussionDetailState {
  const DiscussionDetailLoading();
}

class DiscussionDetailLoaded extends DiscussionDetailState {
  final DiscussionThreadEntity thread;
  final bool isPostingReply;

  const DiscussionDetailLoaded({
    required this.thread,
    this.isPostingReply = false,
  });

  DiscussionDetailLoaded copyWith({
    DiscussionThreadEntity? thread,
    bool? isPostingReply,
  }) {
    return DiscussionDetailLoaded(
      thread: thread ?? this.thread,
      isPostingReply: isPostingReply ?? this.isPostingReply,
    );
  }

  @override
  List<Object?> get props => [thread, isPostingReply];
}

class DiscussionDetailError extends DiscussionDetailState {
  final String message;

  const DiscussionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
