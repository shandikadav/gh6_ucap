part of 'community_bloc.dart';

@immutable
abstract class CommunityEvent extends Equatable {
  const CommunityEvent();
  @override
  List<Object> get props => [];
}

class FetchCommunityData extends CommunityEvent {}

class RefreshCommunityData extends CommunityEvent {}

/// EVENT BARU: Dipicu saat pengguna mengirim pertanyaan baru.
class AddForumQuestion extends CommunityEvent {
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final bool isAnonymous;

  const AddForumQuestion({
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.isAnonymous,
  });

  @override
  List<Object> get props => [title, content, authorId, authorName, isAnonymous];
}
