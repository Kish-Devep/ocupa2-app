import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/shared/models/application.dart';
import 'package:ocupa2/shared/repositories/applications_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  test('POST /offers/{id}/apply envía comment y answers', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/offers/o1/apply',
        statusCode: 201,
        data: applicationJson,
      ),
    ]);

    await ApplicationsRepository(api.client).apply(
      offerId: 'o1',
      comment: 'Tengo 5 años de experiencia.',
      answers: <Map<String, dynamic>>[
        <String, dynamic>{'questionId': 'q1', 'value': true},
      ],
    );

    expect(api.adapter.lastBody, <String, dynamic>{
      'comment': 'Tengo 5 años de experiencia.',
      'answers': <dynamic>[
        <String, dynamic>{'questionId': 'q1', 'value': true},
      ],
    });
  });

  test('POST apply omite answers cuando la oferta no tiene preguntas', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/offers/o1/apply',
        statusCode: 201,
        data: applicationJson,
      ),
    ]);

    await ApplicationsRepository(api.client)
        .apply(offerId: 'o1', comment: 'Me interesa mucho.');

    expect(api.adapter.lastBody.containsKey('answers'), isFalse);
  });

  test('POST apply responde 409 si ya apliqué', () async {
    final api = TestApi.build([
      FakeRoute.error(
        method: 'POST',
        path: '/offers/o1/apply',
        statusCode: 409,
        message: 'Ya aplicaste',
      ),
    ]);

    await expectLater(
      ApplicationsRepository(api.client).apply(offerId: 'o1', comment: 'Hola'),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.conflict)),
    );
  });

  test('GET /me/applications parsea el estado y la oferta anidada', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'GET',
        path: '/me/applications',
        data: <dynamic>[
          applicationJson,
          <String, dynamic>{...applicationJson, 'id': 'a2', 'status': 'winner'},
        ],
      ),
    ]);

    final items = await ApplicationsRepository(api.client).mine();

    expect(items, hasLength(2));
    expect(items.first.status, ApplicationStatus.applied);
    expect(items.first.status.label, 'En revisión');
    expect(items[1].status, ApplicationStatus.winner);
    expect(items.first.offer?.displayTitle, 'Chofer');
  });

  test('GET /offers/{id}/applications responde 403 si no soy el dueño',
      () async {
    final api = TestApi.build([
      FakeRoute.error(
        method: 'GET',
        path: '/offers/o1/applications',
        statusCode: 403,
      ),
    ]);

    await expectLater(
      ApplicationsRepository(api.client).forOffer('o1'),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.forbidden)),
    );
  });

  test('PATCH /applications/{id} envía solo los campos presentes', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'PATCH',
        path: '/applications/a1',
        data: <String, dynamic>{...applicationJson, 'status': 'winner'},
      ),
    ]);

    await ApplicationsRepository(api.client).update(
      'a1',
      status: ApplicationStatus.winner,
      salary: 25000,
      currency: 'DOP',
      startDate: DateTime(2026, 9, 1),
      duration: '3 meses',
    );

    expect(api.adapter.lastBody, <String, dynamic>{
      'status': 'winner',
      'salary': 25000.0,
      'currency': 'DOP',
      'startDate': '2026-09-01',
      'duration': '3 meses',
    });
  });

  test('PATCH solo con rating no manda status', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'PATCH', path: '/applications/a1', data: applicationJson),
    ]);

    await ApplicationsRepository(api.client).update('a1', rating: 4);

    expect(api.adapter.lastBody, <String, dynamic>{'rating': 4});
  });
}
