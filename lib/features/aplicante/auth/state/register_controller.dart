import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import 'session_controller.dart';

class RegisterController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> submit({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(sessionControllerProvider.notifier).register(
            email: email.trim(),
            firstName: firstName.trim(),
            lastName: lastName.trim(),
            password: password,
            referralMatricula: referralMatricula.trim(),
          );
      state = const AsyncData<void>(null);
      return true;
    } on ApiException catch (error, stack) {
      // Mensajes específicos para los dos errores documentados.
      final mapped = switch (error.kind) {
        ApiErrorKind.conflict => const ApiException(
            kind: ApiErrorKind.conflict,
            statusCode: 409,
            message: 'Ese correo ya está registrado. Inicia sesión.',
          ),
        ApiErrorKind.validation => const ApiException(
            kind: ApiErrorKind.validation,
            statusCode: 422,
            message: 'La matrícula de referido no es válida.',
          ),
        _ => error,
      };
      state = AsyncError<void>(mapped, stack);
      return false;
    }
  }
}

final registerControllerProvider =
    AutoDisposeNotifierProvider<RegisterController, AsyncValue<void>>(
  RegisterController.new,
);
