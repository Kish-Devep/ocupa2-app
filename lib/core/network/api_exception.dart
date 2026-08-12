import 'package:dio/dio.dart';

import 'json.dart';

/// Clasificación de errores del API, alineada 1:1 con los códigos documentados.
enum ApiErrorKind {
  network,
  timeout,
  unauthorized, // 401
  paymentRequired, // 402
  forbidden, // 403
  notFound, // 404
  conflict, // 409
  validation, // 422
  storage, // 502 (fallo del bucket de imágenes)
  server, // 5xx
  unknown,
}

/// Excepción única de toda la capa de red. Ni `DioException` ni `SocketException`
/// escapan del `ApiClient`: los repositorios y controladores solo conocen esto.
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.body,
  });

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;
  final JsonMap? body;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          kind: ApiErrorKind.timeout,
          message: 'El servidor tardó demasiado en responder. Intenta de nuevo.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          kind: ApiErrorKind.network,
          message: 'Sin conexión a internet. Revisa tu red e intenta de nuevo.',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          kind: ApiErrorKind.unknown,
          message: 'La operación fue cancelada.',
        );
      default:
        break;
    }

    final response = error.response;
    if (response == null) {
      return const ApiException(
        kind: ApiErrorKind.network,
        message: 'No se pudo contactar el servidor.',
      );
    }
    final body = response.data is Map ? asMap(response.data) : null;
    return ApiException.fromStatus(
      response.statusCode,
      messageFromBody(body),
      body,
    );
  }

  factory ApiException.fromStatus(
    int? statusCode,
    String? serverMessage, [
    JsonMap? body,
  ]) {
    final kind = kindForStatus(statusCode);
    final trimmed = serverMessage?.trim();
    return ApiException(
      kind: kind,
      statusCode: statusCode,
      body: body,
      message: (trimmed != null && trimmed.isNotEmpty)
          ? trimmed
          : defaultMessage(kind),
    );
  }

  static ApiErrorKind kindForStatus(int? status) {
    switch (status) {
      case 401:
        return ApiErrorKind.unauthorized;
      case 402:
        return ApiErrorKind.paymentRequired;
      case 403:
        return ApiErrorKind.forbidden;
      case 404:
        return ApiErrorKind.notFound;
      case 409:
        return ApiErrorKind.conflict;
      case 422:
        return ApiErrorKind.validation;
      case 502:
        return ApiErrorKind.storage;
      default:
        if (status != null && status >= 500) return ApiErrorKind.server;
        return ApiErrorKind.unknown;
    }
  }

  static String defaultMessage(ApiErrorKind kind) {
    switch (kind) {
      case ApiErrorKind.network:
        return 'Sin conexión a internet.';
      case ApiErrorKind.timeout:
        return 'El servidor tardó demasiado en responder.';
      case ApiErrorKind.unauthorized:
        return 'Tu sesión expiró. Inicia sesión de nuevo.';
      case ApiErrorKind.paymentRequired:
        return 'El pago fue rechazado o no es válido.';
      case ApiErrorKind.forbidden:
        return 'No tienes permiso para realizar esta acción.';
      case ApiErrorKind.notFound:
        return 'No encontramos lo que buscabas.';
      case ApiErrorKind.conflict:
        return 'Esta acción ya fue realizada.';
      case ApiErrorKind.validation:
        return 'Hay datos inválidos. Revisa el formulario.';
      case ApiErrorKind.storage:
        return 'No se pudo guardar la imagen. Intenta con otra.';
      case ApiErrorKind.server:
        return 'Error del servidor. Intenta más tarde.';
      case ApiErrorKind.unknown:
        return 'Ocurrió un error inesperado.';
    }
  }

  /// El backend puede reportar el detalle en distintas claves.
  static String? messageFromBody(JsonMap? body) {
    if (body == null) return null;
    for (final key in const ['message', 'error', 'detail', 'msg', 'mensaje']) {
      final value = body[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    final error = body['error'];
    if (error is Map) {
      final nested = asMap(error)['message'];
      if (nested is String && nested.trim().isNotEmpty) return nested;
    }
    return null;
  }

  bool get isUnauthorized => kind == ApiErrorKind.unauthorized;
  bool get isConflict => kind == ApiErrorKind.conflict;
  bool get isValidation => kind == ApiErrorKind.validation;
  bool get isPaymentRequired => kind == ApiErrorKind.paymentRequired;
  bool get isForbidden => kind == ApiErrorKind.forbidden;

  @override
  String toString() => 'ApiException($kind, $statusCode): $message';
}
