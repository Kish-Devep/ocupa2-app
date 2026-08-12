import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/features/aplicante/auth/data/auth_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  group('POST /auth/register', () {
    test('envía exactamente los 5 campos requeridos del schema', () async {
      final api = TestApi.build([
        FakeRoute.ok(
          method: 'POST',
          path: '/auth/register',
          statusCode: 201,
          data: sessionJson,
        ),
      ]);

      final session = await AuthRepository(api.client).register(
        email: 'persona@correo.com',
        firstName: 'Juan',
        lastName: 'Pérez',
        password: 'secreto123',
        referralMatricula: '99999999',
      );

      expect(api.adapter.lastBody, <String, dynamic>{
        'email': 'persona@correo.com',
        'firstName': 'Juan',
        'lastName': 'Pérez',
        'password': 'secreto123',
        'referralMatricula': '99999999',
      });
      expect(session.token, 'jwt-de-prueba');
      expect(session.tokenType, 'Bearer');
      expect(session.user.email, 'persona@correo.com');
    });

    test('409 cuando el correo ya está registrado', () async {
      final api = TestApi.build([
        FakeRoute.error(
          method: 'POST',
          path: '/auth/register',
          statusCode: 409,
          message: 'Correo ya registrado',
        ),
      ]);

      await expectLater(
        AuthRepository(api.client).register(
          email: 'usado@correo.com',
          firstName: 'Juan',
          lastName: 'Pérez',
          password: 'secreto123',
          referralMatricula: '99999999',
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.conflict)),
      );
    });

    test('422 cuando la matrícula de referido no es válida', () async {
      final api = TestApi.build([
        FakeRoute.error(
          method: 'POST',
          path: '/auth/register',
          statusCode: 422,
          message: 'Matrícula de referido no válida',
        ),
      ]);

      await expectLater(
        AuthRepository(api.client).register(
          email: 'nuevo@correo.com',
          firstName: 'Juan',
          lastName: 'Pérez',
          password: 'secreto123',
          referralMatricula: '00000000',
        ),
        throwsA(isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.validation)),
      );
    });
  });

  group('POST /auth/login', () {
    test('envía solo email y password', () async {
      final api = TestApi.build([
        FakeRoute.ok(method: 'POST', path: '/auth/login', data: sessionJson),
      ]);

      final session = await AuthRepository(api.client)
          .login(email: 'persona@correo.com', password: 'secreto123');

      expect(api.adapter.lastBody, <String, dynamic>{
        'email': 'persona@correo.com',
        'password': 'secreto123',
      });
      expect(session.user.profileCompleted, isTrue);
    });

    test('401 con credenciales incorrectas', () async {
      final api = TestApi.build([
        FakeRoute.error(method: 'POST', path: '/auth/login', statusCode: 401),
      ]);

      await expectLater(
        AuthRepository(api.client)
            .login(email: 'persona@correo.com', password: 'mala'),
        throwsA(isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.unauthorized)),
      );
    });
  });

  test('POST /auth/forgot-password envía email + referralMatricula', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'POST', path: '/auth/forgot-password', data: null),
    ]);

    await AuthRepository(api.client).forgotPassword(
      email: 'persona@correo.com',
      referralMatricula: '99999999',
    );

    expect(api.adapter.lastBody, <String, dynamic>{
      'email': 'persona@correo.com',
      'referralMatricula': '99999999',
    });
  });
}
