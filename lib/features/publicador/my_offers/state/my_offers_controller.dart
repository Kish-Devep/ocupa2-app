import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/offer.dart';
import '../../../../shared/providers/offers_provider.dart';
import '../../offers/state/explore_offers_controller.dart';

class MyOffersController extends AsyncNotifier<List<Offer>> {
  @override
  Future<List<Offer>> build() => ref.watch(offersRepositoryProvider).myOffers();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(offersRepositoryProvider).myOffers(),
    );
  }

  /// POST /offers/{id}/deactivate. Propaga 403/404/409 tal cual para que la
  /// pantalla muestre el mensaje correcto.
  Future<void> deactivate(String offerId) async {
    await ref.read(offersRepositoryProvider).deactivate(offerId);
    ref.invalidate(exploreOffersProvider);
    await refresh();
  }
}

final myOffersControllerProvider =
    AsyncNotifierProvider<MyOffersController, List<Offer>>(
  MyOffersController.new,
);
