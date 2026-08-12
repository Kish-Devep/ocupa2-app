import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocupa2/core/config/api_config.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/features/publicador/payments/data/payment_request.dart';
import 'package:ocupa2/features/publicador/payments/data/payments_repository.dart';
import 'package:ocupa2/features/publicador/publish_offer/state/publish_offer_controller.dart';
import 'package:ocupa2/shared/models/offer.dart';
import 'package:ocupa2/shared/models/offer_input.dart';
import 'package:ocupa2/shared/models/custom_field.dart';
import 'package:ocupa2/shared/models/payment.dart';
import 'package:ocupa2/shared/models/upload_result.dart';
import 'package:ocupa2/shared/providers/offers_provider.dart';
import 'package:ocupa2/shared/providers/upload_provider.dart';
import 'package:ocupa2/shared/widgets/photo_picker_field.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

class _FakeOfferInput extends Fake implements OfferInput {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeOfferInput());
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(
      const PaymentRequest(
        cardNumber: ApiConfig.testCardApproved,
        cardName: 'x',
        expiry: '12/30',
        cvv: '123',
      ),
    );
  });

  late MockUploadRepository upload;
  late MockPaymentsRepository payments;
  late MockOffersRepository offers;
  late ProviderContainer container;

  const card = PaymentRequest(
    cardNumber: ApiConfig.testCardApproved,
    cardName: 'Juan Pérez',
    expiry: '12/30',
    cvv: '123',
  );

  PublishOfferController controller() =>
      container.read(publishOfferControllerProvider.notifier);

  PublishOfferState state() => container.read(publishOfferControllerProvider);

  setUp(() {
    upload = MockUploadRepository();
    payments = MockPaymentsRepository();
    offers = MockOffersRepository();

    container = ProviderContainer(
      overrides: <Override>[
        uploadRepositoryProvider.overrideWithValue(upload),
        paymentsRepositoryProvider.overrideWithValue(payments),
        offersRepositoryProvider.overrideWithValue(offers),
      ],
    );
    // Mantiene vivo el provider autoDispose durante todo el test.
    container.listen(publishOfferControllerProvider, (_, __) {});
    addTearDown(container.dispose);
  });

  void fillValidDetails() {
    controller()
      ..setJobType(testJobType)
      ..setContractType(ContractType.temporal)
      ..setDescription('Se necesita chofer para reparto.')
      ..setAddress('Ensanche Naco, D.N.')
      ..setAmount(2500)
      ..setPhoto(PickedPhoto(
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        filename: 'foto.jpg',
      ));
  }

  test('detailsValid exige tipo de empleo, descripción, dirección, monto y foto',
      () {
    expect(state().detailsValid, isFalse);

    controller().setJobType(testJobType);
    expect(state().detailsValid, isFalse);

    fillValidDetails();
    expect(state().detailsValid, isTrue);

    controller().setPhoto(null);
    expect(state().detailsValid, isFalse, reason: 'la foto es obligatoria');
  });

  test('flujo feliz: sube foto → cobra → publica, en ese orden', () async {
    late OfferInput capturedInput;

    when(() => upload.uploadImage(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        )).thenAnswer(
      (_) async => const UploadResult(url: 'https://cdn.ocupa2.test/foto.jpg'),
    );
    when(() => payments.charge(any()))
        .thenAnswer((_) async => const Payment(id: 'pay_1', status: 'approved'));
    // Capturamos el argumento directamente dentro del stub (no con un
    // verify(captureAny()) aparte): así evitamos el conflicto de mocktail
    // donde verifyInOrder "consume" una llamada y un verify() posterior
    // sobre esa misma llamada ya no la encuentra (y viceversa).
    when(() => offers.create(any())).thenAnswer((invocation) async {
      capturedInput = invocation.positionalArguments.first as OfferInput;
      return testOffer;
    });

    fillValidDetails();
    final ok = await controller().payAndPublish(card);

    expect(ok, isTrue);
    expect(state().created, isNotNull);
    expect(state().submitting, isFalse);

    expect(capturedInput.photo, 'https://cdn.ocupa2.test/foto.jpg');
    expect(capturedInput.paymentId, 'pay_1');
    expect(capturedInput.jobTypeKey, 'chofer');

    verifyInOrder(<dynamic Function()>[
      () => upload.uploadImage(
            bytes: any(named: 'bytes'),
            filename: any(named: 'filename'),
          ),
      () => payments.charge(any()),
      () => offers.create(any()),
    ]);
  });

  test('sin datos obligatorios no llama a ningún endpoint', () async {
    final ok = await controller().payAndPublish(card);

    expect(ok, isFalse);
    expect(state().error, isA<ApiException>());
    verifyNever(() => upload.uploadImage(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ));
    verifyNever(() => payments.charge(any()));
    verifyNever(() => offers.create(any()));
  });

  test('tarjeta rechazada (402): mensaje claro y NO se publica la oferta',
      () async {
    when(() => upload.uploadImage(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        )).thenAnswer(
      (_) async => const UploadResult(url: 'https://cdn.ocupa2.test/foto.jpg'),
    );
    when(() => payments.charge(any())).thenThrow(
      const ApiException(
        kind: ApiErrorKind.paymentRequired,
        statusCode: 402,
        message: 'Pago rechazado',
      ),
    );

    fillValidDetails();
    final ok = await controller().payAndPublish(card);

    expect(ok, isFalse);
    expect((state().error as ApiException).kind, ApiErrorKind.paymentRequired);
    expect(state().paymentId, isNull);
    expect(state().created, isNull);
    verifyNever(() => offers.create(any()));
  });

  test('si POST /offers falla, reintentar NO vuelve a cobrar ni a subir la foto',
      () async {
    when(() => upload.uploadImage(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        )).thenAnswer(
      (_) async => const UploadResult(url: 'https://cdn.ocupa2.test/foto.jpg'),
    );
    when(() => payments.charge(any()))
        .thenAnswer((_) async => const Payment(id: 'pay_1'));
    when(() => offers.create(any())).thenThrow(
      const ApiException(kind: ApiErrorKind.server, message: 'boom'),
    );

    fillValidDetails();
    expect(await controller().payAndPublish(card), isFalse);
    expect(state().paymentId, 'pay_1');
    expect(state().photoUrl, 'https://cdn.ocupa2.test/foto.jpg');

    // Segundo intento: ahora sí publica.
    when(() => offers.create(any())).thenAnswer((_) async => testOffer);
    expect(await controller().payAndPublish(card), isTrue);

    verify(() => payments.charge(any())).called(1);
    verify(() => upload.uploadImage(
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        )).called(1);
  });

  test('el constructor de preguntas agrega y elimina correctamente', () {
    controller().addQuestion(const OfferQuestionInput(
      label: '¿Tienes vehículo?',
      type: CustomFieldType.check,
    ));
    expect(state().questions, hasLength(1));

    controller().removeQuestion(0);
    expect(state().questions, isEmpty);
  });
}
