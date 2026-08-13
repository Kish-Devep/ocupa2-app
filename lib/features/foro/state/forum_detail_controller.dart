import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/forum_topic_detail.dart';
import '../../../shared/providers/forum_provider.dart';

class ForumDetailController
    extends AutoDisposeFamilyAsyncNotifier<ForumTopicDetail, String> {
  @override
  Future<ForumTopicDetail> build(String topicId) =>
      ref.watch(forumRepositoryProvider).detail(topicId);

  Future<void> addComment(String body) async {
    await ref.read(forumRepositoryProvider).addComment(
          topicId: arg,
          body: body,
        );
    ref.invalidateSelf();
  }
}

final forumDetailControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ForumDetailController, ForumTopicDetail, String>(
  ForumDetailController.new,
);