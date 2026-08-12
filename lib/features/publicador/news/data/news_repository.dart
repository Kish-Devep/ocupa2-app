import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/models/news_item.dart';

class NewsRepository {
  NewsRepository(this._client);

  final ApiClient _client;

  /// GET /news?limit= — endpoint PÚBLICO, no requiere token.
  Future<List<NewsItem>> list({int limit = 20}) => _client.get<List<NewsItem>>(
        '/news',
        query: <String, dynamic>{'limit': limit},
        parse: (data) => asModelList(data, NewsItem.fromJson),
      );
}

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => NewsRepository(ref.watch(apiClientProvider)),
);

/// Options reutilizables para endpoints públicos: omiten el header Authorization.
final publicOptions = Options(
  extra: const <String, dynamic>{'requiresAuth': false},
);
