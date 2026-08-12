import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import 'session_controller.dart';

class ForgotPasswordController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> submit({
    required String email,
    required String referralMatricula,
  }) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(authRepositoryProvider).forgotPassword(
            email: email.trim(),
            referralMatricula: referralMatricula.trim(),
          );
      state = const AsyncData<void>(null);
      return true;
    } on ApiException catch (error, stack) {
      state = AsyncError<void>(error, stack);
      return false;
    }
  }
}

final forgotPasswordControllerProvider =
    AutoDisposeNotifierProvider<ForgotPasswordController, AsyncValue<void>>(
  ForgotPasswordController.new,
);
