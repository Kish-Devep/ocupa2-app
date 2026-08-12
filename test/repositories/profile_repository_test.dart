import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/features/aplicante/profile/data/profile_repository.dart';
import 'package:ocupa2/shared/models/user.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  test('GET /me devuelve el usuario autenticado', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/me', data: userJson),
    ]);

    final user = await ProfileRepository(api.client).me();

    expect(user.id, 'u1');
    expect(user.displayName, 'Juan Pérez');
    expect(user.gender, Gender.masculino);
    expect(user.profileCompleted, isTrue);
  });

  test('PUT /me/profile envía el body exacto del schema', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'PUT', path: '/me/profile', data: userJson),
    ]);

    await ProfileRepository(api.client).updateProfile(
      firstName: 'Juan',
      lastName: 'Pérez',
      cedula: '402-1234567-8', // con guiones: deben limpiarse
      gender: Gender.masculino,
      birthDate: DateTime(2004, 5, 17),
    );

    expect(api.adapter.lastBody, <String, dynamic>{
      'firstName': 'Juan',
      'lastName': 'Pérez',
      'cedula': '40212345678',
      'gender': 'masculino',
      'birthDate': '2004-05-17', // format: date, no date-time
    });
  });

  test('PUT /me/profile devuelve 422 con datos inválidos', () async {
    final api = TestApi.build([
      FakeRoute.error(method: 'PUT', path: '/me/profile', statusCode: 422),
    ]);

    await expectLater(
      ProfileRepository(api.client).updateProfile(
        firstName: 'J',
        lastName: 'P',
        cedula: '123',
        gender: Gender.otro,
        birthDate: DateTime(2004, 5, 17),
      ),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.validation)),
    );
  });

  test('PUT /me/password envía solo el campo password', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'PUT', path: '/me/password', data: null),
    ]);

    await ProfileRepository(api.client).changePassword('nuevaClave1');

    expect(api.adapter.lastBody, <String, dynamic>{'password': 'nuevaClave1'});
  });
}
