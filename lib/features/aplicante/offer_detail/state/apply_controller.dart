import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../shared/providers/applications_provider.dart';
import '../../applications/state/my_applications_controller.dart';

class ApplyController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<bool> submit({
    required String offerId,
    required String comment,
    required List<Map<String, dynamic>> answers,
  }) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(applicationsRepositoryProvider).apply(
            offerId: offerId,
            comment: comment.trim(),
            answers: answers,
          );
      // La lista de "Mis aplicaciones" queda obsoleta: se invalida.
      ref.invalidate(myApplicationsControllerProvider);
      state = const AsyncData<void>(null);
      return true;
    } on ApiException catch (error, stack) {
      final mapped = error.isConflict
          ? const ApiException(
              kind: ApiErrorKind.conflict,
              statusCode: 409,
              message: 'Ya aplicaste a esta oferta.',
            )
          : error;
      state = AsyncError<void>(mapped, stack);
      return false;
    }
  }
}

final applyControllerProvider =
    AutoDisposeNotifierProvider<ApplyController, AsyncValue<void>>(
  ApplyController.new,
);
