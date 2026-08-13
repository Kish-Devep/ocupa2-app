import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/shared/models/offer.dart';

import '../helpers/fixtures.dart';

void main() {
  test('parsea applicantsCount y status published del JSON real', () {
    final offer = Offer.fromJson(realMyOfferJson);

    expect(offer.status, OfferStatus.published);
    expect(offer.isPublished, isTrue);
    expect(offer.applicantsCount, 1);
  });

  test('parsea una oferta inactive como desactivada', () {
    final offer = Offer.fromJson(<String, dynamic>{
      ...realMyOfferJson,
      'status': 'inactive',
      'applicantsCount': 0,
    });

    expect(offer.status, OfferStatus.inactive);
    expect(offer.isPublished, isFalse);
    expect(offer.status.label, 'Desactivada');
  });

  test('parsea una oferta closed como cerrada con ganador', () {
    final offer = Offer.fromJson(<String, dynamic>{
      ...realMyOfferJson,
      'status': 'closed',
      'applicantsCount': 1,
      'winnerApplicationId': 'winner-1',
    });

    expect(offer.status, OfferStatus.closed);
    expect(offer.isPublished, isFalse);
    expect(offer.status.label, 'Cerrada');
  });
}