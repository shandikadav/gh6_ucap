import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ForumQuestion extends Equatable {
  final String id;
  final String title;
  final String authorId;
  final String content;
  final String authorName;
  final bool isAnonymous;
  final int replyCount;
  final Timestamp createdAt;

  const ForumQuestion({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.isAnonymous,
    required this.replyCount,
    required this.createdAt,
    required this.authorId,
  });

  factory ForumQuestion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ForumQuestion(
      id: doc.id,
      title: data['title'] ?? 'Tanpa Judul',
      content: data['content'] ?? '',
      authorName: data['authorName'] ?? 'Anonim',
      isAnonymous: data['isAnonymous'] ?? false,
      authorId: data['authorId'] ?? '',
      replyCount: data['replyCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    authorName,
    isAnonymous,
    replyCount,
    createdAt,
  ];
}

class Mentor extends Equatable {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String profilePictureUrl;
  final bool isOnline;
  final List<String> skills;

  const Mentor({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    required this.profilePictureUrl,
    required this.isOnline,
    required this.skills,
  });

  factory Mentor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Mentor(
      id: doc.id,
      name: data['name'] ?? 'Tanpa Nama',
      title: data['title'] ?? 'Mentor',
      bio: data['bio'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      isOnline: data['isOnline'] ?? false,
      skills: List<String>.from(data['skills'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    title,
    bio,
    profilePictureUrl,
    isOnline,
    skills,
  ];
}
