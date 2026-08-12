import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/offer.dart';
import '../../../../shared/providers/offers_provider.dart';

/// GET /offers/{id}. `family` por id, autoDispose para no cachear ofertas
/// que el usuario ya cerró.
final offerDetailProvider = FutureProvider.autoDispose.family<Offer, String>(
  (ref, id) => ref.watch(offersRepositoryProvider).detail(id),
);
