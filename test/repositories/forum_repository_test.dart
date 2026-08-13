import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/features/foro/data/forum_repository.dart';

import '../helpers/mocks.dart';

void main() {
  const author = <String, dynamic>{'id': 'u1', 'nombre': 'Ana'};
  const topic = <String, dynamic>{
    'id': 't1',
    'title': 'Trabajo',
    'description': 'Hablemos de oportunidades.',
    'author': author,
    'commentsCount': 1,
    'createdAt': '2026-08-12T20:00:00Z',
    'lastActivityAt': '2026-08-12T20:10:00Z',
  };

  test('GET /forum/topics parsea temas', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/forum/topics', data: <dynamic>[topic]),
    ]);
    final result = await ForumRepository(api.client).topics();
    expect(result.single.author?.nombre, 'Ana');
    expect(result.single.commentsCount, 1);
  });

  test('POST /forum/topics envía solo title y description', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'POST', path: '/forum/topics', statusCode: 201, data: <String, dynamic>{...topic, 'author': null}),
    ]);
    await ForumRepository(api.client).createTopic(title: 'Trabajo', description: 'Texto');
    expect(api.adapter.lastBody, <String, dynamic>{'title': 'Trabajo', 'description': 'Texto'});
  });

  test('GET detail parsea comentarios y author requerido', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/forum/topics/t1', data: <String, dynamic>{
        ...topic,
        'comments': <dynamic>[<String, dynamic>{
          'id': 'c1', 'body': 'Comentario', 'author': author, 'createdAt': '2026-08-12T20:20:00Z',
        }],
      }),
    ]);
    final result = await ForumRepository(api.client).detail('t1');
    expect(result.author.id, 'u1');
    expect(result.comments.single.body, 'Comentario');
  });

  test('POST comentario envía body', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'POST', path: '/forum/topics/t1/comments', statusCode: 201, data: <String, dynamic>{
        'id': 'c1', 'body': 'Hola', 'author': author, 'createdAt': '2026-08-12T20:20:00Z',
      }),
    ]);
    await ForumRepository(api.client).addComment(topicId: 't1', body: 'Hola');
    expect(api.adapter.lastBody, <String, dynamic>{'body': 'Hola'});
  });
}