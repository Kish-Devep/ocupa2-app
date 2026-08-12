import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/shared/models/geo_point.dart';
import 'package:ocupa2/shared/models/offer.dart';
import 'package:ocupa2/shared/models/offer_input.dart';
import 'package:ocupa2/shared/models/custom_field.dart';
import 'package:ocupa2/shared/repositories/offers_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  test('GET /offers manda jobTypeKey y contractType como query', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/offers', data: <dynamic>[offerJson]),
    ]);

    final offers = await OffersRepository(api.client)
        .explore(jobTypeKey: 'chofer', contractType: 'temporal');

    expect(api.adapter.lastRequest.queryParameters, <String, dynamic>{
      'jobTypeKey': 'chofer',
      'contractType': 'temporal',
    });
    expect(offers, hasLength(1));
    expect(offers.first.contractType, ContractType.temporal);
    expect(offers.first.location?.lat, 18.4861);
    expect(offers.first.questions, hasLength(1));
    expect(offers.first.questions.first.field.type, CustomFieldType.check);
  });

  test('GET /offers/{id} oculta al publicante cuando el API no lo envía',
      () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/offers/o1', data: offerJson),
    ]);

    final offer = await OffersRepository(api.client).detail('o1');

    expect(offer.publisher, isNull);
  });

  test('GET /offers/{id} revela al publicante cuando soy el ganador', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'GET',
        path: '/offers/o1',
        data: <String, dynamic>{...offerJson, 'publisher': userJson},
      ),
    ]);

    final offer = await OffersRepository(api.client).detail('o1');

    expect(offer.publisher, isNotNull);
    expect(offer.publisher!.displayName, 'Juan Pérez');
  });

  test('POST /offers serializa OfferInput 1:1 con el schema', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/offers',
        statusCode: 201,
        data: offerJson,
      ),
    ]);

    await OffersRepository(api.client).create(
      OfferInput(
        jobTypeKey: 'chofer',
        contractType: ContractType.temporal,
        description: 'Reparto en la zona colonial.',
        address: 'Ensanche Naco, D.N.',
        photo: 'https://cdn.ocupa2.test/foto.jpg',
        paymentId: 'pay_1',
        payment: const OfferPayment(amount: 2500, currency: 'DOP'),
        location: const GeoPoint(lat: 18.4861, lng: -69.9312),
        deadline: DateTime(2026, 8, 30),
        customAnswers: const <String, dynamic>{'categoria_licencia': '03'},
        questions: const <OfferQuestionInput>[
          OfferQuestionInput(
            label: '¿Tienes vehículo propio?',
            type: CustomFieldType.check,
            required: true,
          ),
        ],
      ),
    );

    final body = api.adapter.lastBody;
    expect(body['jobTypeKey'], 'chofer');
    expect(body['contractType'], 'temporal');
    expect(body['description'], 'Reparto en la zona colonial.');
    expect(body['address'], 'Ensanche Naco, D.N.');
    expect(body['photo'], 'https://cdn.ocupa2.test/foto.jpg');
    expect(body['paymentId'], 'pay_1');
    expect(body['payment'], <String, dynamic>{'amount': 2500.0, 'currency': 'DOP'});
    expect(body['location'], <String, dynamic>{'lat': 18.4861, 'lng': -69.9312});
    expect(body['deadline'], '2026-08-30');
    expect(body['customAnswers'], <String, dynamic>{'categoria_licencia': '03'});
    expect(body['questions'], <dynamic>[
      <String, dynamic>{
        'label': '¿Tienes vehículo propio?',
        'type': 'check',
        'required': true,
      },
    ]);
  });

  test('POST /offers omite del body los opcionales nulos', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/offers',
        statusCode: 201,
        data: offerJson,
      ),
    ]);

    await OffersRepository(api.client).create(
      const OfferInput(
        jobTypeKey: 'chofer',
        contractType: ContractType.fijo,
        description: 'Descripción mínima válida.',
        address: 'Piantini',
        photo: 'https://cdn.ocupa2.test/foto.jpg',
        paymentId: 'pay_1',
        payment: OfferPayment(amount: 18000, currency: 'DOP'),
      ),
    );

    final body = api.adapter.lastBody;
    expect(body.containsKey('location'), isFalse);
    expect(body.containsKey('deadline'), isFalse);
    expect(body.containsKey('customAnswers'), isFalse);
    expect(body.containsKey('questions'), isFalse);
  });

  test('POST /offers responde 402 si el pago es inválido', () async {
    final api = TestApi.build([
      FakeRoute.error(method: 'POST', path: '/offers', statusCode: 402),
    ]);

    await expectLater(
      OffersRepository(api.client).create(
        const OfferInput(
          jobTypeKey: 'chofer',
          contractType: ContractType.horas,
          description: 'Descripción mínima válida.',
          address: 'Naco',
          photo: 'https://cdn.ocupa2.test/foto.jpg',
          paymentId: 'pago_invalido',
          payment: OfferPayment(amount: 800, currency: 'DOP'),
        ),
      ),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.paymentRequired)),
    );
  });

  test('POST /offers/{id}/deactivate responde 403 si no soy el dueño', () async {
    final api = TestApi.build([
      FakeRoute.error(
        method: 'POST',
        path: '/offers/o1/deactivate',
        statusCode: 403,
      ),
    ]);

    await expectLater(
      OffersRepository(api.client).deactivate('o1'),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.forbidden)),
    );
  });

  test('POST /offers/{id}/deactivate responde 409 si ya estaba desactivada',
      () async {
    final api = TestApi.build([
      FakeRoute.error(
        method: 'POST',
        path: '/offers/o1/deactivate',
        statusCode: 409,
      ),
    ]);

    await expectLater(
      OffersRepository(api.client).deactivate('o1'),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.conflict)),
    );
  });
}
