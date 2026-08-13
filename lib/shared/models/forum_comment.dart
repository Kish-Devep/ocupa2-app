import '../../core/network/json.dart';
import 'forum_author.dart';

class ForumComment {
  const ForumComment({
    required this.id,
    required this.body,
    required this.author,
    required this.createdAt,
  });

  final String id;
  final String body;
  final ForumAuthor author;
  final DateTime? createdAt;

  factory ForumComment.fromJson(JsonMap json) => ForumComment(
        id: asString(json['id']),
        body: asString(json['body']),
        author: ForumAuthor.fromJson(asMap(json['author'])),
        createdAt: asDate(json['createdAt']),
      );
}