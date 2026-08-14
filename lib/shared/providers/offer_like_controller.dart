import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../models/offer.dart';
import 'offers_provider.dart';

class OfferLikeNotifier extends StateNotifier<Offer> {
  OfferLikeNotifier(this._ref, Offer initial) : super(initial);

  final Ref _ref;

  Future<void> toggle() async {
    final previous = state;
    final nextLiked = !previous.likedByMe;
    state = previous.copyWith(
      likedByMe: nextLiked,
      likesCount: (previous.likesCount + (nextLiked ? 1 : -1))
          .clamp(0, 1 << 30),
    );
    try {
      final result = nextLiked
          ? await _ref.read(offersRepositoryProvider).like(state.id)
          : await _ref.read(offersRepositoryProvider).unlike(state.id);
      state = state.copyWith(
        likedByMe: result.liked,
        likesCount: result.likesCount,
      );
    } on ApiException {
      state = previous;
      rethrow;
    }
  }
}

final offerLikeProvider = StateNotifierProvider.autoDispose
    .family<OfferLikeNotifier, Offer, Offer>(
  (ref, offer) => OfferLikeNotifier(ref, offer),
);