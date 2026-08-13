import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/offer.dart';
import '../../../../shared/providers/offers_provider.dart';

class MyLikesController extends AsyncNotifier<List<Offer>> {
  @override
  Future<List<Offer>> build() =>
      ref.watch(offersRepositoryProvider).myLikes();

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(offersRepositoryProvider).myLikes(),
    );
  }
}

final myLikesControllerProvider =
    AsyncNotifierProvider<MyLikesController, List<Offer>>(
  MyLikesController.new,
);