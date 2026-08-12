import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/features/publicador/news/data/news_repository.dart';

import '../helpers/mocks.dart';

void main() {
  test('GET /news manda el parámetro limit y parsea NewsItem', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'GET',
        path: '/news',
        data: <dynamic>[
          <String, dynamic>{
            'title': 'Empleos en auge',
            'image': 'https://remolacha.net/foto.jpg',
            'summary': 'Resumen en texto plano.',
            'date': '2026-08-10T16:44:59-04:00',
            'url': 'https://remolacha.net/articulo',
            'source': 'remolacha.net',
          },
        ],
      ),
    ]);

    final items = await NewsRepository(api.client).list(limit: 5);

    expect(api.adapter.lastRequest.queryParameters['limit'], 5);
    expect(items, hasLength(1));
    expect(items.first.title, 'Empleos en auge');
    expect(items.first.source, 'remolacha.net');
    expect(items.first.date, isNotNull);
  });
}
