import '../../core/network/json.dart';
import 'forum_author.dart';
import 'forum_comment.dart';

class ForumTopicDetail {
  const ForumTopicDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.commentsCount,
    required this.createdAt,
    required this.lastActivityAt,
    required this.comments,
  });

  final String id;
  final String title;
  final String description;
  final ForumAuthor author;
  final int commentsCount;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;
  final List<ForumComment> comments;

  factory ForumTopicDetail.fromJson(JsonMap json) => ForumTopicDetail(
        id: asString(json['id']),
        title: asString(json['title']),
        description: asString(json['description']),
        author: ForumAuthor.fromJson(asMap(json['author'])),
        commentsCount: asInt(json['commentsCount']) ?? 0,
        createdAt: asDate(json['createdAt']),
        lastActivityAt: asDate(json['lastActivityAt']),
        comments: asModelList(json['comments'], ForumComment.fromJson),
      );
}