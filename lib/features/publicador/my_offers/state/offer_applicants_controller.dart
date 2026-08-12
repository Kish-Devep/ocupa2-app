import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/application.dart';
import '../../../../shared/providers/applications_provider.dart';
import '../../contracts/state/my_contracts_controller.dart';

/// GET /offers/{id}/applications + PATCH /applications/{id}.
class OfferApplicantsController
    extends AutoDisposeFamilyAsyncNotifier<List<Application>, String> {
  @override
  Future<List<Application>> build(String offerId) =>
      ref.watch(applicationsRepositoryProvider).forOffer(offerId);

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(applicationsRepositoryProvider).forOffer(arg),
    );
  }

  Future<void> setStatus(
    String applicationId,
    ApplicationStatus status, {
    double? salary,
    String? currency,
    DateTime? startDate,
    String? duration,
  }) async {
    final updated = await ref.read(applicationsRepositoryProvider).update(
          applicationId,
          status: status,
          salary: salary,
          currency: currency,
          startDate: startDate,
          duration: duration,
        );
    _replace(updated);

    // status = winner crea un contrato automáticamente en el backend.
    if (status == ApplicationStatus.winner) {
      ref.invalidate(myContractsProvider);
    }
  }

  Future<void> setRating(String applicationId, int rating) async {
    final updated = await ref
        .read(applicationsRepositoryProvider)
        .update(applicationId, rating: rating);
    _replace(updated);
  }

  void _replace(Application updated) {
    final current = state.valueOrNull ?? const <Application>[];
    state = AsyncData<List<Application>>([
      for (final application in current)
        if (application.id == updated.id) updated else application,
    ]);
  }
}

final offerApplicantsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<OfferApplicantsController, List<Application>, String>(
  OfferApplicantsController.new,
);
