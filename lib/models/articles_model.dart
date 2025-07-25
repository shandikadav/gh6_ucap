import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorHex;
  final int sortOrder;
  final bool isActive;
  final int totalArticles;

  ArticleCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorHex,
    required this.sortOrder,
    required this.isActive,
    required this.totalArticles,
  });

  factory ArticleCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleCategory(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? 'article',
      colorHex: data['colorHex'] ?? '#2196F3',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      totalArticles: data['totalArticles'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'totalArticles': totalArticles,
    };
  }
}

class Article {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final String type; // 'article' or 'video'
  final int expReward;
  final int readTime;
  final String? videoUrl;
  final bool isActive;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.type,
    required this.expReward,
    required this.readTime,
    this.videoUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Article(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      categoryId: data['categoryId'] ?? '',
      type: data['type'] ?? 'article',
      expReward: data['expReward'] ?? 10,
      readTime: data['readTime'] ?? 5,
      videoUrl: data['videoUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'type': type,
      'expReward': expReward,
      'readTime': readTime,
      'videoUrl': videoUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
