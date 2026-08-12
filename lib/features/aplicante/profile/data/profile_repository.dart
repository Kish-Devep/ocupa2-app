import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/user.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  /// GET /me — módulo 8: valida la sesión y alimenta la app.
  Future<User> me() => _client.get<User>(
        '/me',
        parse: (data) => User.fromJson(asMap(data)),
      );

  /// PUT /me/profile — módulo 2. Body 1:1 con el schema.
  /// La cédula se envía solo con dígitos (el API ignora guiones, pero enviar
  /// limpio evita ambigüedades). 422 si algún dato es inválido.
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required Gender gender,
    required DateTime birthDate,
  }) =>
      _client.put<User>(
        '/me/profile',
        body: <String, dynamic>{
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'cedula': Validators.digitsOnly(cedula),
          'gender': gender.apiValue,
          'birthDate': DateFormats.apiDate(birthDate),
        },
        parse: (data) => User.fromJson(asMap(data)),
      );

  /// PUT /me/password — módulo 3. Body: `{password}` con minLength 6.
  Future<void> changePassword(String password) => _client.put<void>(
        '/me/password',
        body: <String, dynamic>{'password': password},
        parse: (_) {},
      );
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);
