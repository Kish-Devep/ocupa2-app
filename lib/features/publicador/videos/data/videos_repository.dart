import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/models/video.dart';

class VideosRepository {
  VideosRepository(this._client);

  final ApiClient _client;

  /// GET /videos — endpoint PÚBLICO.
  Future<List<Video>> list() => _client.get<List<Video>>(
        '/videos',
        parse: (data) {
          final videos = asModelList(data, Video.fromJson);
          final sorted = [...videos]
            ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
          return sorted;
        },
      );
}

final videosRepositoryProvider = Provider<VideosRepository>(
  (ref) => VideosRepository(ref.watch(apiClientProvider)),
);
