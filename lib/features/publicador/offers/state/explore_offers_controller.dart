import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/offer.dart';
import '../../../../shared/providers/offers_provider.dart';
import 'offers_filter.dart';

/// GET /offers con los filtros del servidor (`jobTypeKey`, `contractType`).
/// Se re-ejecuta solo cuando cambian esos dos; la búsqueda por texto es local.
final exploreOffersProvider = FutureProvider<List<Offer>>((ref) {
  final filter = ref.watch(offersFilterProvider);
  return ref.watch(offersRepositoryProvider).explore(
        jobTypeKey: filter.jobTypeKey,
        contractType: filter.contractType?.apiValue,
      );
});

/// Lista final que ve el usuario: resultado del API + filtro local por texto.
final visibleOffersProvider = Provider<AsyncValue<List<Offer>>>((ref) {
  final filter = ref.watch(offersFilterProvider);
  return ref.watch(exploreOffersProvider).whenData(filter.apply);
});

/// Módulo 13 — solo las ofertas que traen lat/lng.
final mappableOffersProvider = Provider<AsyncValue<List<Offer>>>((ref) {
  return ref
      .watch(visibleOffersProvider)
      .whenData((offers) => offers.where((o) => o.hasLocation).toList());
});
