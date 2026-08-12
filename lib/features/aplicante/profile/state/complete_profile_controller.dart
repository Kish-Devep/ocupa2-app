import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../shared/models/user.dart';
import '../../auth/state/session_controller.dart';
import '../data/profile_repository.dart';

class CompleteProfileController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> submit({
    required String firstName,
    required String lastName,
    required String cedula,
    required Gender gender,
    required DateTime birthDate,
  }) async {
    state = const AsyncLoading<void>();
    try {
      final user = await ref.read(profileRepositoryProvider).updateProfile(
            firstName: firstName,
            lastName: lastName,
            cedula: cedula,
            gender: gender,
            birthDate: birthDate,
          );
      // El API responde con profileCompleted = true: se refleja de inmediato
      // en la sesión y el guard del router deja de redirigir.
      ref.read(sessionControllerProvider.notifier).setUser(user);
      state = const AsyncData<void>(null);
      return true;
    } on ApiException catch (error, stack) {
      final mapped = error.isValidation
          ? const ApiException(
              kind: ApiErrorKind.validation,
              statusCode: 422,
              message:
                  'Datos inválidos. Revisa la cédula (11 dígitos) y la fecha '
                  'de nacimiento.',
            )
          : error;
      state = AsyncError<void>(mapped, stack);
      return false;
    }
  }
}

final completeProfileControllerProvider =
    AutoDisposeNotifierProvider<CompleteProfileController, AsyncValue<void>>(
  CompleteProfileController.new,
);
