import '../../core/network/json.dart';
import 'forum_author.dart';

class ForumTopic {
  const ForumTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.commentsCount,
    required this.createdAt,
    required this.lastActivityAt,
    this.author,
  });

  final String id;
  final String title;
  final String description;
  final ForumAuthor? author;
  final int commentsCount;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;

  factory ForumTopic.fromJson(JsonMap json) => ForumTopic(
        id: asString(json['id']),
        title: asString(json['title']),
        description: asString(json['description']),
        author: json['author'] is Map
            ? ForumAuthor.fromJson(asMap(json['author']))
            : null,
        commentsCount: asInt(json['commentsCount']) ?? 0,
        createdAt: asDate(json['createdAt']),
        lastActivityAt: asDate(json['lastActivityAt']),
      );
}