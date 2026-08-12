import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/features/publicador/my_offers/presentation/my_offers_screen.dart';
import 'package:ocupa2/shared/models/offer.dart';
import 'package:ocupa2/shared/providers/offers_provider.dart';
import 'package:ocupa2/shared/widgets/offer_card.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockOffersRepository offers;

  setUp(() => offers = MockOffersRepository());

  List<Override> overrides() => <Override>[
        offersRepositoryProvider.overrideWithValue(offers),
      ];

  testWidgets('lista mis ofertas con su estado y conteo de aplicantes',
      (tester) async {
    when(() => offers.myOffers()).thenAnswer((_) async => <Offer>[
          testOffer,
          Offer.fromJson(<String, dynamic>{
            ...offerJson,
            'id': 'o2',
            'active': false,
            'applicationsCount': 1,
          }),
        ]);

    await mockNetworkImagesFor(() async {
      await tester.pumpApp(const MyOffersScreen(), overrides: overrides());
      await tester.pumpAndSettle();
    });

    expect(find.byType(OfferCard), findsNWidgets(2));
    expect(find.text('Activa'), findsOneWidget);
    expect(find.text('Desactivada'), findsOneWidget);
    expect(find.text('3 aplicantes'), findsOneWidget);
    expect(find.text('1 aplicante'), findsOneWidget);
  });

  testWidgets('solo la oferta activa ofrece el botón de desactivar',
      (tester) async {
    when(() => offers.myOffers()).thenAnswer((_) async => <Offer>[
          Offer.fromJson(<String, dynamic>{...offerJson, 'active': false}),
        ]);

    await mockNetworkImagesFor(() async {
      await tester.pumpApp(const MyOffersScreen(), overrides: overrides());
      await tester.pumpAndSettle();
    });

    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
  });

  testWidgets('desactivar pide confirmación y llama al endpoint',
      (tester) async {
    when(() => offers.myOffers()).thenAnswer((_) async => <Offer>[testOffer]);
    when(() => offers.deactivate(any())).thenAnswer((_) async {});

    await mockNetworkImagesFor(() async {
      await tester.pumpApp(const MyOffersScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Desactivar oferta'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
      await tester.pumpAndSettle();
    });

    verify(() => offers.deactivate('o1')).called(1);
  });

  testWidgets('un 403 al desactivar muestra el mensaje del API', (tester) async {
    when(() => offers.myOffers()).thenAnswer((_) async => <Offer>[testOffer]);
    when(() => offers.deactivate(any())).thenThrow(const ApiException(
      kind: ApiErrorKind.forbidden,
      statusCode: 403,
      message: 'No eres el publicante.',
    ));

    await mockNetworkImagesFor(() async {
      await tester.pumpApp(const MyOffersScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Desactivar'));
      await tester.pumpAndSettle();
    });

    expect(find.text('No eres el publicante.'), findsOneWidget);
  });

  testWidgets('estado vacío invita a publicar', (tester) async {
    when(() => offers.myOffers()).thenAnswer((_) async => <Offer>[]);

    await tester.pumpApp(const MyOffersScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.text('Todavía no publicaste ninguna oferta'), findsOneWidget);
    expect(find.text('Publicar oferta'), findsOneWidget);
  });
}
