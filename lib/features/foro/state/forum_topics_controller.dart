import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/forum_topic.dart';
import '../../../shared/providers/forum_provider.dart';

class ForumTopicsController extends AsyncNotifier<List<ForumTopic>> {
  @override
  Future<List<ForumTopic>> build() =>
      ref.watch(forumRepositoryProvider).topics();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(forumRepositoryProvider).topics(),
    );
  }

  Future<void> create({required String title, required String description}) async {
    final created = await ref.read(forumRepositoryProvider).createTopic(
          title: title,
          description: description,
        );
    state = AsyncData<List<ForumTopic>>([
      created,
      ...(state.valueOrNull ?? const <ForumTopic>[]),
    ]);
  }
}

final forumTopicsControllerProvider =
    AsyncNotifierProvider<ForumTopicsController, List<ForumTopic>>(
  ForumTopicsController.new,
);