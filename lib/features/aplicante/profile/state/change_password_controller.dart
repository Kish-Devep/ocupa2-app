import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../data/profile_repository.dart';

class ChangePasswordController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> submit(String password) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(profileRepositoryProvider).changePassword(password);
      state = const AsyncData<void>(null);
      return true;
    } on ApiException catch (error, stack) {
      state = AsyncError<void>(error, stack);
      return false;
    }
  }
}

final changePasswordControllerProvider =
    AutoDisposeNotifierProvider<ChangePasswordController, AsyncValue<void>>(
  ChangePasswordController.new,
);
