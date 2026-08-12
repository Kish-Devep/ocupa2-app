import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/news_item.dart';
import '../data/news_repository.dart';

final newsLimitProvider = StateProvider<int>((ref) => 20);

final newsProvider = FutureProvider.autoDispose<List<NewsItem>>(
  (ref) => ref.watch(newsRepositoryProvider).list(
        limit: ref.watch(newsLimitProvider),
      ),
);
