import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import 'session_controller.dart';

class LoginController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> submit({required String email, required String password}) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(sessionControllerProvider.notifier).login(
            email: email.trim(),
            password: password,
          );
      state = const AsyncData<void>(null);
      return true;
    } on ApiException catch (error, stack) {
      // En /auth/login un 401 significa credenciales incorrectas,
      // no "sesión expirada".
      final mapped = error.isUnauthorized
          ? const ApiException(
              kind: ApiErrorKind.unauthorized,
              statusCode: 401,
              message: 'Correo o clave incorrectos.',
            )
          : error;
      state = AsyncError<void>(mapped, stack);
      return false;
    }
  }
}

final loginControllerProvider =
    AutoDisposeNotifierProvider<LoginController, AsyncValue<void>>(
  LoginController.new,
);
