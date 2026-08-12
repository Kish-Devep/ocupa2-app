import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/offer.dart';

/// Estado inmutable de los filtros de exploración.
/// Los valores viajan tal cual a `GET /offers?jobTypeKey=&contractType=`.
class OffersFilter {
  const OffersFilter({this.jobTypeKey, this.contractType, this.query = ''});

  final String? jobTypeKey;
  final ContractType? contractType;

  /// Búsqueda local por texto: el API no expone parámetro de búsqueda.
  final String query;

  bool get isEmpty =>
      jobTypeKey == null && contractType == null && query.trim().isEmpty;

  int get activeCount =>
      (jobTypeKey == null ? 0 : 1) + (contractType == null ? 0 : 1);

  OffersFilter copyWith({
    String? jobTypeKey,
    ContractType? contractType,
    String? query,
    bool clearJobType = false,
    bool clearContractType = false,
  }) =>
      OffersFilter(
        jobTypeKey: clearJobType ? null : (jobTypeKey ?? this.jobTypeKey),
        contractType:
            clearContractType ? null : (contractType ?? this.contractType),
        query: query ?? this.query,
      );

  /// Filtro local por texto, aplicado sobre lo que devolvió el API.
  /// Función pura → testeada en `offers_filter_test.dart`.
  List<Offer> apply(List<Offer> offers) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return offers;
    return offers.where((offer) {
      return offer.displayTitle.toLowerCase().contains(needle) ||
          offer.description.toLowerCase().contains(needle) ||
          offer.address.toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  @override
  bool operator ==(Object other) =>
      other is OffersFilter &&
      other.jobTypeKey == jobTypeKey &&
      other.contractType == contractType &&
      other.query == query;

  @override
  int get hashCode => Object.hash(jobTypeKey, contractType, query);
}

class OffersFilterNotifier extends Notifier<OffersFilter> {
  @override
  OffersFilter build() => const OffersFilter();

  void setJobType(String? key) => state = key == null
      ? state.copyWith(clearJobType: true)
      : state.copyWith(jobTypeKey: key);

  void setContractType(ContractType? type) => state = type == null
      ? state.copyWith(clearContractType: true)
      : state.copyWith(contractType: type);

  void setQuery(String query) => state = state.copyWith(query: query);

  void clear() => state = const OffersFilter();
}

final offersFilterProvider =
    NotifierProvider<OffersFilterNotifier, OffersFilter>(
  OffersFilterNotifier.new,
);
