import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_providers.dart';
import '../../features/foro/data/forum_repository.dart';
import '../models/forum_topic.dart';

final forumRepositoryProvider = Provider<ForumRepository>(
  (ref) => ForumRepository(ref.watch(apiClientProvider)),
);

final forumTopicsProvider = FutureProvider.autoDispose<List<ForumTopic>>(
  (ref) => ref.watch(forumRepositoryProvider).topics(),
);