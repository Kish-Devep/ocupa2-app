import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/core/network/json.dart';

import '../helpers/mocks.dart';

void main() {
  group('ApiClient.unwrap — el sobre {ok, data}', () {
    test('devuelve data cuando ok = true', () {
      final result = ApiClient.unwrap(<String, dynamic>{
        'ok': true,
        'data': <String, dynamic>{'id': 'x'},
      });
      expect(result, <String, dynamic>{'id': 'x'});
    });

    test('devuelve una lista cuando data es un array', () {
      final result = ApiClient.unwrap(<String, dynamic>{
        'ok': true,
        'data': <dynamic>[1, 2, 3],
      });
      expect(result, <dynamic>[1, 2, 3]);
    });

    test('devuelve {} cuando ok = true pero no hay data', () {
      expect(ApiClient.unwrap(<String, dynamic>{'ok': true}), <String, dynamic>{});
    });

    test('lanza ApiException cuando ok = false aunque el HTTP sea 200', () {
      expect(
        () => ApiClient.unwrap(<String, dynamic>{
          'ok': false,
          'message': 'Algo salió mal',
        }),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'Algo salió mal'),
        ),
      );
    });

    test('es tolerante: si no hay sobre, devuelve el cuerpo tal cual', () {
      expect(ApiClient.unwrap(<String, dynamic>{'id': 'x'}),
          <String, dynamic>{'id': 'x'});
    });
  });

  group('ApiClient — desenvoltura centralizada en peticiones reales', () {
    test('GET desenvuelve data sin que el repositorio toque ["data"]', () async {
      final api = TestApi.build([
        FakeRoute.ok(method: 'GET', path: '/me', data: <String, dynamic>{'id': 'u1'}),
      ]);

      final id = await api.client.get<String>(
        '/me',
        parse: (data) => asMap(data)['id'] as String,
      );

      expect(id, 'u1');
    });

    test('omite los parámetros de query nulos o vacíos', () async {
      final api = TestApi.build([
        FakeRoute.ok(method: 'GET', path: '/offers', data: <dynamic>[]),
      ]);

      await api.client.get<void>(
        '/offers',
        query: <String, dynamic>{'jobTypeKey': null, 'contractType': ''},
        parse: (_) {},
      );

      expect(api.adapter.lastRequest.queryParameters, isEmpty);
    });
  });

  group('Mapeo de los códigos de error documentados', () {
    Future<ApiException> callWith(int status) async {
      final api = TestApi.build([
        FakeRoute.error(method: 'GET', path: '/x', statusCode: status),
      ]);
      try {
        await api.client.get<void>('/x', parse: (_) {});
      } on ApiException catch (e) {
        return e;
      }
      fail('Se esperaba una ApiException para el status $status');
    }

    test('401 → unauthorized', () async {
      expect((await callWith(401)).kind, ApiErrorKind.unauthorized);
    });

    test('402 → paymentRequired (pago rechazado)', () async {
      expect((await callWith(402)).kind, ApiErrorKind.paymentRequired);
    });

    test('403 → forbidden (no eres el dueño)', () async {
      expect((await callWith(403)).kind, ApiErrorKind.forbidden);
    });

    test('409 → conflict (ya existe / ya aplicaste)', () async {
      expect((await callWith(409)).kind, ApiErrorKind.conflict);
    });

    test('422 → validation (datos inválidos)', () async {
      expect((await callWith(422)).kind, ApiErrorKind.validation);
    });

    test('502 → storage (fallo del bucket de imágenes)', () async {
      expect((await callWith(502)).kind, ApiErrorKind.storage);
    });

    test('usa el mensaje del servidor cuando viene en el cuerpo', () async {
      final api = TestApi.build([
        FakeRoute.error(
          method: 'POST',
          path: '/auth/register',
          statusCode: 409,
          message: 'Correo ya registrado',
        ),
      ]);

      await expectLater(
        api.client.post<void>('/auth/register', parse: (_) {}),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', 'Correo ya registrado')),
      );
    });
  });
}
