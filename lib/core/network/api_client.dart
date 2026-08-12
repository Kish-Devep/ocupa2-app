import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exception.dart';
import 'json.dart';

/// Cliente HTTP centralizado y ÚNICO de la aplicación (ambas áreas).
///
/// Responsabilidad clave: **desenvolver el sobre `{ok, data}` en un solo lugar**.
/// Ningún repositorio ni modelo accede jamás a `json['data']`.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  @visibleForTesting
  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    JsonMap? query,
    required T Function(dynamic data) parse,
  }) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: _cleanQuery(query)), parse);

  Future<T> post<T>(
    String path, {
    Object? body,
    required T Function(dynamic data) parse,
  }) =>
      _send(() => _dio.post<dynamic>(path, data: body), parse);

  Future<T> put<T>(
    String path, {
    Object? body,
    required T Function(dynamic data) parse,
  }) =>
      _send(() => _dio.put<dynamic>(path, data: body), parse);

  Future<T> patch<T>(
    String path, {
    Object? body,
    required T Function(dynamic data) parse,
  }) =>
      _send(() => _dio.patch<dynamic>(path, data: body), parse);

  Future<T> delete<T>(
    String path, {
    Object? body,
    required T Function(dynamic data) parse,
  }) =>
      _send(() => _dio.delete<dynamic>(path, data: body), parse);

  Future<T> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) parse,
  ) async {
    try {
      final response = await request();
      return parse(unwrap(response.data));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        kind: ApiErrorKind.unknown,
        message: 'La respuesta del servidor no tiene el formato esperado.',
      );
    }
  }

  /// EL punto único de desenvoltura del sobre estándar del API Ocupa2.
  ///
  /// Todas las respuestas documentadas tienen la forma `{"ok": bool, "data": ...}`.
  /// - `ok == true`  → devuelve `data` (o `{}` si el endpoint no trae cuerpo).
  /// - `ok == false` → lanza `ApiException` aunque el HTTP haya sido 200.
  /// - Sin sobre     → devuelve el cuerpo tal cual (defensivo).
  @visibleForTesting
  static dynamic unwrap(dynamic body) {
    if (body is Map) {
      final map = asMap(body);
      if (map.containsKey('ok')) {
        if (asBool(map['ok'])) {
          return map.containsKey('data') ? map['data'] : const <String, dynamic>{};
        }
        throw ApiException(
          kind: ApiErrorKind.unknown,
          body: map,
          message: ApiException.messageFromBody(map) ??
              'La operación no pudo completarse.',
        );
      }
    }
    return body;
  }

  /// Quita nulos y strings vacíos para no mandar `?jobTypeKey=` sin valor.
  static JsonMap? _cleanQuery(JsonMap? query) {
    if (query == null) return null;
    final cleaned = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      cleaned[key] = value;
    });
    return cleaned.isEmpty ? null : cleaned;
  }
}
