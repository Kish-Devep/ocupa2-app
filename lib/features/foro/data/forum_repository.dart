import '../../../core/network/api_client.dart';
import '../../../core/network/json.dart';
import '../../../shared/models/forum_comment.dart';
import '../../../shared/models/forum_topic.dart';
import '../../../shared/models/forum_topic_detail.dart';

class ForumRepository {
  ForumRepository(this._client);

  final ApiClient _client;

  Future<List<ForumTopic>> topics() => _client.get<List<ForumTopic>>(
        '/forum/topics',
        parse: (data) => asModelList(data, ForumTopic.fromJson),
      );

  Future<ForumTopic> createTopic({
    required String title,
    required String description,
  }) => _client.post<ForumTopic>(
        '/forum/topics',
        body: <String, dynamic>{
          'title': title.trim(),
          'description': description.trim(),
        },
        parse: (data) => ForumTopic.fromJson(asMap(data)),
      );

  Future<ForumTopicDetail> detail(String id) =>
      _client.get<ForumTopicDetail>(
        '/forum/topics/$id',
        parse: (data) => ForumTopicDetail.fromJson(asMap(data)),
      );

  Future<ForumComment> addComment({
    required String topicId,
    required String body,
  }) => _client.post<ForumComment>(
        '/forum/topics/$topicId/comments',
        body: <String, dynamic>{'body': body.trim()},
        parse: (data) => ForumComment.fromJson(asMap(data)),
      );
}