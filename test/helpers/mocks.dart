import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocupa2/core/config/api_config.dart';
import 'package:ocupa2/core/network/api_client.dart';
import 'package:ocupa2/core/network/interceptors/auth_interceptor.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/shared/repositories/applications_repository.dart';
import 'package:ocupa2/shared/repositories/offers_repository.dart';
import 'package:ocupa2/shared/repositories/upload_repository.dart';
import 'package:ocupa2/features/aplicante/auth/data/auth_repository.dart';
import 'package:ocupa2/features/aplicante/experiences/data/experiences_repository.dart';
import 'package:ocupa2/features/aplicante/profile/data/profile_repository.dart';
import 'package:ocupa2/features/publicador/payments/data/payments_repository.dart';

/// IMPORTANTE: si el `name:` de tu `pubspec.yaml` no es `ocupa2`, reemplaza
/// `package:ocupa2/` por `package:<tu_nombre>/` en TODOS los tests.

/// Una respuesta simulada del API.
class FakeRoute {
  FakeRoute({
    required this.method,
    required this.path,
    this.statusCode = 200,
    this.body,
  });

  /// Atajo para el sobre estándar `{ok: true, data: ...}`.
  factory FakeRoute.ok({
    required String method,
    required String path,
    int statusCode = 200,
    required Object? data,
  }) =>
      FakeRoute(
        method: method,
        path: path,
        statusCode: statusCode,
        body: <String, dynamic>{'ok': true, 'data': data},
      );

  /// Atajo para un error documentado del API.
  factory FakeRoute.error({
    required String method,
    required String path,
    required int statusCode,
    String? message,
  }) =>
      FakeRoute(
        method: method,
        path: path,
        statusCode: statusCode,
        body: <String, dynamic>{'ok': false, 'message': message},
      );

  final String method;
  final String path;
  final int statusCode;
  final Object? body;
}

/// Adaptador que sustituye la red real. Permite testear el ApiClient completo
/// (interceptores + sobre + errores) sin un solo byte de tráfico.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.routes);

  final List<FakeRoute> routes;

  /// Todas las peticiones que pasaron por aquí, para verificar bodies y headers.
  final List<RequestOptions> requests = <RequestOptions>[];

  RequestOptions get lastRequest => requests.last;

  Map<String, dynamic> get lastBody =>
      Map<String, dynamic>.from(lastRequest.data as Map);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final route = routes.cast<FakeRoute?>().firstWhere(
          (r) =>
              r!.method.toUpperCase() == options.method.toUpperCase() &&
              r.path == options.path,
          orElse: () => null,
        );

    if (route == null) {
      throw StateError(
        'Ruta no simulada en el test: ${options.method} ${options.path}',
      );
    }

    return ResponseBody.fromString(
      jsonEncode(route.body ?? <String, dynamic>{'ok': true, 'data': null}),
      route.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Construye un ApiClient idéntico al de producción pero sin red.
class TestApi {
  TestApi._(this.client, this.adapter, this.tokens, this.unauthorizedCount);

  final ApiClient client;
  final FakeHttpAdapter adapter;
  final TokenStorage tokens;
  final List<int> unauthorizedCount;

  bool get unauthorizedFired => unauthorizedCount.isNotEmpty;

  static TestApi build(List<FakeRoute> routes, {String? token}) {
    final adapter = FakeHttpAdapter(routes);
    final tokens = InMemoryTokenStorage(token);
    final fired = <int>[];

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: const <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    )..httpClientAdapter = adapter;

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokens,
        onUnauthorized: () => fired.add(1),
      ),
    );

    return TestApi._(ApiClient(dio), adapter, tokens, fired);
  }
}

// ---- Mocks de repositorios para los widget tests -------------------------

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockExperiencesRepository extends Mock implements ExperiencesRepository {}

class MockOffersRepository extends Mock implements OffersRepository {}

class MockApplicationsRepository extends Mock
    implements ApplicationsRepository {}

class MockPaymentsRepository extends Mock implements PaymentsRepository {}

class MockUploadRepository extends Mock implements UploadRepository {}
