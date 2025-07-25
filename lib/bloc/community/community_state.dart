part of 'community_bloc.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();
  @override
  List<Object> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<ForumQuestion> questions;
  final List<Mentor> mentors;

  const CommunityLoaded({required this.questions, required this.mentors});

  @override
  List<Object> get props => [questions, mentors];
}

class CommunityCreatingQuestion extends CommunityState {
  final List<ForumQuestion> questions;
  final List<Mentor> mentors;

  const CommunityCreatingQuestion({
    required this.questions,
    required this.mentors,
  });

  @override
  List<Object> get props => [questions, mentors];
}

class CommunityQuestionCreated extends CommunityState {}

class CommunityError extends CommunityState {
  final String message;

  const CommunityError({required this.message});

  @override
  List<Object> get props => [message];
}
