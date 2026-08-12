import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// Adjunta `Authorization: Bearer <token>` a toda petición autenticada y
/// reacciona al 401 cerrando la sesión.
///
/// Para omitir el header en un endpoint público (`/news`, `/videos`) se pasa
/// `Options(extra: {AuthInterceptor.requiresAuthKey: false})`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.onUnauthorized,
  });

  static const String requiresAuthKey = 'requiresAuth';

  final TokenStorage tokenStorage;
  final void Function() onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra[requiresAuthKey] != false;
    if (requiresAuth) {
      final token = await tokenStorage.read();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    // Un 401 en /auth/login significa "credenciales incorrectas", no
    // "sesión expirada": no debe desloguear ni redirigir.
    final isAuthEndpoint = path.startsWith('/auth/');

    if (status == 401 && !isAuthEndpoint) {
      await tokenStorage.clear();
      onUnauthorized();
    }
    handler.next(err);
  }
}
