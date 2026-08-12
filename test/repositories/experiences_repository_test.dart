import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/features/aplicante/experiences/data/experiences_repository.dart';

import '../helpers/mocks.dart';

void main() {
  const experienceJson = <String, dynamic>{
    'id': 'e1',
    'title': 'Ayudante de electricista',
    'description': 'Dos años instalando cableado residencial.',
    'jobTypeKey': 'electricista',
    'certificateImage': 'https://cdn.ocupa2.test/cert.jpg',
  };

  test('GET /me/experiences devuelve la lista', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'GET',
        path: '/me/experiences',
        data: <dynamic>[experienceJson],
      ),
    ]);

    final items = await ExperiencesRepository(api.client).list();

    expect(items, hasLength(1));
    expect(items.first.title, 'Ayudante de electricista');
    expect(items.first.certificateImage, 'https://cdn.ocupa2.test/cert.jpg');
  });

  test('POST /me/experiences omite los opcionales cuando son nulos', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/me/experiences',
        statusCode: 201,
        data: experienceJson,
      ),
    ]);

    await ExperiencesRepository(api.client).add(
      title: 'Mesero',
      description: 'Eventos de fin de semana.',
    );

    expect(api.adapter.lastBody, <String, dynamic>{
      'title': 'Mesero',
      'description': 'Eventos de fin de semana.',
    });
  });

  test('POST /me/experiences incluye jobTypeKey y certificateImage', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/me/experiences',
        statusCode: 201,
        data: experienceJson,
      ),
    ]);

    await ExperiencesRepository(api.client).add(
      title: 'Chofer',
      description: 'Reparto en motor.',
      jobTypeKey: 'chofer',
      certificateImage: 'https://cdn.ocupa2.test/cert.jpg',
    );

    expect(api.adapter.lastBody['jobTypeKey'], 'chofer');
    expect(
      api.adapter.lastBody['certificateImage'],
      'https://cdn.ocupa2.test/cert.jpg',
    );
  });

  test('DELETE /me/experiences/{id} llama la ruta correcta', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'DELETE', path: '/me/experiences/e1', data: null),
    ]);

    await ExperiencesRepository(api.client).remove('e1');

    expect(api.adapter.lastRequest.path, '/me/experiences/e1');
  });
}
