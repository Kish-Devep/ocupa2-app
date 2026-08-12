import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../shared/models/auth_session.dart';

/// Endpoints de `/auth/*`. Login exclusivamente con **correo + clave**
/// (`POST /auth/login`), tal como define el schema OpenAPI.
class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// POST /auth/register (201).
  /// 409 correo ya registrado · 422 matrícula de referido no válida.
  Future<AuthSession> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) =>
      _client.post<AuthSession>(
        '/auth/register',
        body: <String, dynamic>{
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
          'referralMatricula': referralMatricula,
        },
        parse: (data) => AuthSession.fromJson(asMap(data)),
      );

  /// POST /auth/login (200). 401 correo o clave incorrectos.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) =>
      _client.post<AuthSession>(
        '/auth/login',
        body: <String, dynamic>{
          'email': email,
          'password': password,
        },
        parse: (data) => AuthSession.fromJson(asMap(data)),
      );

  /// POST /auth/forgot-password (200). Envía una clave temporal al correo.
  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) =>
      _client.post<void>(
        '/auth/forgot-password',
        body: <String, dynamic>{
          'email': email,
          'referralMatricula': referralMatricula,
        },
        parse: (_) {},
      );
}
