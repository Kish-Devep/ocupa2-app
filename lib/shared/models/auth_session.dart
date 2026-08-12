import '../../core/network/json.dart';
import 'user.dart';

/// Respuesta de POST /auth/register (201) y POST /auth/login (200).
class AuthSession {
  const AuthSession({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final User user;

  factory AuthSession.fromJson(JsonMap json) => AuthSession(
        token: asString(json['token']),
        tokenType: asString(json['tokenType'], fallback: 'Bearer'),
        user: User.fromJson(asMap(json['user'])),
      );
}
