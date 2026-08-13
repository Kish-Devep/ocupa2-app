import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:ocupa2/features/publicador/payments/data/payment_request.dart';
import 'package:ocupa2/features/publicador/payments/data/payments_repository.dart';
import 'package:ocupa2/features/publicador/publish_offer/presentation/step1_details_screen.dart';
import 'package:ocupa2/features/publicador/publish_offer/presentation/step3_payment_screen.dart';
import 'package:ocupa2/shared/models/job_type.dart';
import 'package:ocupa2/shared/providers/job_types_provider.dart';
import 'package:ocupa2/shared/providers/offers_provider.dart';
import 'package:ocupa2/shared/providers/upload_provider.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';

class _FakePaymentRequest extends Fake implements PaymentRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePaymentRequest());
  });

  late MockUploadRepository upload;
  late MockPaymentsRepository payments;
  late MockOffersRepository offers;

  setUp(() {
    upload = MockUploadRepository();
    payments = MockPaymentsRepository();
    offers = MockOffersRepository();
  });

  List<Override> overrides() => <Override>[
        jobTypesProvider.overrideWith((ref) async => <JobType>[testJobType]),
        uploadRepositoryProvider.overrideWithValue(upload),
        paymentsRepositoryProvider.overrideWithValue(payments),
        offersRepositoryProvider.overrideWithValue(offers),
      ];

  testWidgets('paso 1 renderiza los campos obligatorios del OfferInput',
      (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpApp(
        const Scaffold(body: Step1DetailsScreen()),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();
    });

    expect(find.byKey(const Key('publish_job_type')), findsOneWidget);
    expect(find.byKey(const Key('publish_description')), findsOneWidget);
    expect(find.byKey(const Key('publish_address')), findsOneWidget);
    expect(find.byKey(const Key('publish_amount')), findsOneWidget);
    // La foto es obligatoria y el selector debe estar presente.
    expect(find.byKey(const Key('photo_picker_tap')), findsOneWidget);
    // No existe campo "Título del empleo": no está en el schema OfferInput.
    expect(find.text('Título del empleo'), findsNothing);
  });

  testWidgets('paso 1 no avanza sin la foto obligatoria', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpApp(
        const Scaffold(body: Step1DetailsScreen()),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('publish_description')),
        'Se necesita chofer para reparto en la zona colonial.',
      );
      await tester.enterText(
        find.byKey(const Key('publish_address')),
        'Ensanche Naco',
      );
      await tester.enterText(find.byKey(const Key('publish_amount')), '2500');

      await tester.tap(find.byKey(const Key('publish_step1_next')));
      await tester.pumpAndSettle();
    });

    expect(find.textContaining('foto'), findsWidgets);
  });

  testWidgets('paso 3 valida la tarjeta antes de cobrar', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpApp(
      const Scaffold(body: Step3PaymentScreen()),
      overrides: overrides(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('publish_pay_button')));
    await tester.pumpAndSettle();

    expect(find.text('El número de tarjeta es obligatorio'), findsOneWidget);
    expect(find.text('El vencimiento es obligatorio'), findsOneWidget);
    expect(find.text('El CVV es obligatorio'), findsOneWidget);
    verifyNever(() => payments.charge(any()));
  });

  testWidgets('paso 3 rechaza un número de tarjeta que no pasa Luhn',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpApp(
      const Scaffold(body: Step3PaymentScreen()),
      overrides: overrides(),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('card_number')),
      '4242424242424243',
    );
    await tester.tap(find.byKey(const Key('publish_pay_button')));
    await tester.pumpAndSettle();

    expect(find.text('Número de tarjeta no válido'), findsOneWidget);
    verifyNever(() => payments.charge(any()));
  });
}
