import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_events.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/models/user.dart';
import '../../profile/data/profile_repository.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

/// Estado global de sesión.
///
/// `null`  → no autenticado.
/// `User`  → autenticado; `user.profileCompleted` decide el segundo guard.
///
/// Módulo 8 del mandato: `GET /me` es lo que valida la sesión al abrir la app,
/// no la mera existencia del token (que podría estar expirado).
class SessionController extends AsyncNotifier<User?> {
  TokenStorage get _tokens => ref.read(tokenStorageProvider);
  AuthRepository get _auth => ref.read(authRepositoryProvider);
  ProfileRepository get _profile => ref.read(profileRepositoryProvider);

  @override
  Future<User?> build() async {
    // El interceptor avisa cuando el API responde 401 en un endpoint privado.
    final subscription =
        ref.watch(authEventsProvider).onUnauthorized.listen((_) {
      state = const AsyncData(null);
    });
    ref.onDispose(subscription.cancel);

    return _restore();
  }

  Future<User?> _restore() async {
    final token = await _tokens.read();
    if (token == null || token.isEmpty) return null;
    try {
      return await _profile.me();
    } on ApiException catch (error) {
      // Token inválido o expirado: se descarta en silencio y se pide login.
      if (error.isUnauthorized) {
        await _tokens.clear();
        return null;
      }
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await _auth.login(email: email, password: password);
    await _tokens.write(session.token);
    state = AsyncData(session.user);
  }

  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    final session = await _auth.register(
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
      referralMatricula: referralMatricula,
    );
    // El registro ya devuelve JWT: el usuario queda autenticado y el router
    // lo manda directo a completar el perfil.
    await _tokens.write(session.token);
    state = AsyncData(session.user);
  }

  /// Refresca desde GET /me. Se llama después de PUT /me/profile.
  Future<void> refresh() async {
    final user = await _profile.me();
    state = AsyncData(user);
  }

  void setUser(User user) => state = AsyncData(user);

  Future<void> logout() async {
    await _tokens.clear();
    state = const AsyncData(null);
  }
}

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, User?>(SessionController.new);

/// Atajo para las pantallas que solo necesitan el usuario ya cargado.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(sessionControllerProvider).valueOrNull,
);
