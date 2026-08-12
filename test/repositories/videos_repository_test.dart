import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/features/publicador/videos/data/videos_repository.dart';

import '../helpers/mocks.dart';

void main() {
  test('GET /videos ordena por order y deriva la miniatura de YouTube',
      () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'GET',
        path: '/videos',
        data: <dynamic>[
          <String, dynamic>{
            'id': 'v2',
            'youtubeId': 'bbb',
            'title': 'Segundo',
            'order': 2,
          },
          <String, dynamic>{
            'id': 'v1',
            'youtubeId': 'aaa',
            'title': 'Primero',
            'order': 1,
          },
        ],
      ),
    ]);

    final videos = await VideosRepository(api.client).list();

    expect(videos.map((v) => v.id), <String>['v1', 'v2']);
    expect(
      videos.first.thumbnail,
      'https://img.youtube.com/vi/aaa/hqdefault.jpg',
    );
    expect(videos.first.watchUrl, 'https://www.youtube.com/watch?v=aaa');
  });
}
