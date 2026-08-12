import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/features/publicador/offers/state/offers_filter.dart';
import 'package:ocupa2/shared/models/offer.dart';

import '../helpers/fixtures.dart';

void main() {
  final chofer = testOffer;
  final mesero = Offer.fromJson(<String, dynamic>{
    ...offerJson,
    'id': 'o2',
    'jobTypeKey': 'mesero',
    'jobTypeName': 'Mesero para evento',
    'contractType': 'horas',
    'description': 'Servicio de mesa en boda.',
    'address': 'Boca Chica',
  });
  final offers = <Offer>[chofer, mesero];

  test('sin query devuelve todas las ofertas', () {
    expect(const OffersFilter().apply(offers), hasLength(2));
  });

  test('filtra por título', () {
    final result = const OffersFilter(query: 'mesero').apply(offers);
    expect(result, hasLength(1));
    expect(result.first.id, 'o2');
  });

  test('filtra por dirección', () {
    final result = const OffersFilter(query: 'naco').apply(offers);
    expect(result.single.id, 'o1');
  });

  test('filtra por descripción y es insensible a mayúsculas', () {
    expect(const OffersFilter(query: 'BODA').apply(offers).single.id, 'o2');
  });

  test('ignora espacios alrededor del término', () {
    expect(const OffersFilter(query: '   ').apply(offers), hasLength(2));
  });

  test('devuelve vacío cuando nada coincide', () {
    expect(const OffersFilter(query: 'astronauta').apply(offers), isEmpty);
  });

  group('estado del filtro', () {
    test('isEmpty y activeCount', () {
      const empty = OffersFilter();
      expect(empty.isEmpty, isTrue);
      expect(empty.activeCount, 0);

      const withBoth = OffersFilter(
        jobTypeKey: 'chofer',
        contractType: ContractType.temporal,
      );
      expect(withBoth.isEmpty, isFalse);
      expect(withBoth.activeCount, 2);
    });

    test('copyWith limpia correctamente con las banderas clear*', () {
      const filter = OffersFilter(
        jobTypeKey: 'chofer',
        contractType: ContractType.fijo,
      );
      expect(filter.copyWith(clearJobType: true).jobTypeKey, isNull);
      expect(filter.copyWith(clearContractType: true).contractType, isNull);
      // Lo no tocado se conserva.
      expect(filter.copyWith(clearJobType: true).contractType, ContractType.fijo);
    });
  });
}
