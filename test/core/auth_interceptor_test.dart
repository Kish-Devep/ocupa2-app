import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/core/network/interceptors/auth_interceptor.dart';

import '../helpers/mocks.dart';

void main() {
  test('adjunta Authorization: Bearer <token> cuando hay sesión', () async {
    final api = TestApi.build(
      [FakeRoute.ok(method: 'GET', path: '/me', data: <String, dynamic>{})],
      token: 'jwt-de-prueba',
    );

    await api.client.get<void>('/me', parse: (_) {});

    expect(
      api.adapter.lastRequest.headers['Authorization'],
      'Bearer jwt-de-prueba',
    );
  });

  test('no adjunta el header cuando no hay token', () async {
    final api = TestApi.build(
      [FakeRoute.ok(method: 'GET', path: '/news', data: <dynamic>[])],
    );

    await api.client.get<void>('/news', parse: (_) {});

    expect(api.adapter.lastRequest.headers.containsKey('Authorization'), isFalse);
  });

  test('respeta requiresAuth = false en los endpoints públicos', () async {
    final api = TestApi.build(
      [FakeRoute.ok(method: 'GET', path: '/news', data: <dynamic>[])],
      token: 'jwt-de-prueba',
    );

    await api.client.dio.get<dynamic>(
      '/news',
      options: Options(
        extra: const <String, dynamic>{AuthInterceptor.requiresAuthKey: false},
      ),
    );

    expect(api.adapter.lastRequest.headers.containsKey('Authorization'), isFalse);
  });

  test('un 401 en endpoint privado limpia el token y avisa a la sesión',
      () async {
    final api = TestApi.build(
      [FakeRoute.error(method: 'GET', path: '/me', statusCode: 401)],
      token: 'jwt-viejo',
    );

    await expectLater(
      api.client.get<void>('/me', parse: (_) {}),
      throwsA(isA<ApiException>()),
    );

    expect(await api.tokens.read(), isNull);
    expect(api.unauthorizedFired, isTrue);
  });

  test('un 401 en /auth/login NO cierra sesión: son credenciales incorrectas',
      () async {
    final api = TestApi.build(
      [FakeRoute.error(method: 'POST', path: '/auth/login', statusCode: 401)],
      token: 'jwt-existente',
    );

    await expectLater(
      api.client.post<void>('/auth/login', parse: (_) {}),
      throwsA(isA<ApiException>()),
    );

    expect(await api.tokens.read(), 'jwt-existente');
    expect(api.unauthorizedFired, isFalse);
  });
}
