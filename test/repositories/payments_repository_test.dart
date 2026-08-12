import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/config/api_config.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/features/publicador/payments/data/payment_request.dart';
import 'package:ocupa2/features/publicador/payments/data/payments_repository.dart';

import '../helpers/mocks.dart';

void main() {
  const approved = PaymentRequest(
    cardNumber: ApiConfig.testCardApproved,
    cardName: 'Juan Pérez',
    expiry: '12/30',
    cvv: '123',
  );

  test('POST /payments con la tarjeta aprobada devuelve el paymentId', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'POST',
        path: '/payments',
        statusCode: 201,
        data: <String, dynamic>{
          'id': 'pay_1',
          'amount': 1,
          'currency': 'USD',
          'status': 'approved',
          'last4': '4242',
        },
      ),
    ]);

    final payment = await PaymentsRepository(api.client).charge(approved);

    expect(payment.id, 'pay_1');
    expect(payment.isApproved, isTrue);
    expect(api.adapter.lastBody['cardNumber'], '4242424242424242');
    expect(api.adapter.lastBody['expMonth'], 12);
    expect(api.adapter.lastBody['expYear'], 2030);
    expect(api.adapter.lastBody['cardholder'], 'Juan Pérez');
    expect(api.adapter.lastBody.containsKey('amount'), isFalse);
    expect(api.adapter.lastBody.containsKey('currency'), isFalse);
  });

  test('POST /payments con la tarjeta rechazada devuelve 402', () async {
    final api = TestApi.build([
      FakeRoute.error(
        method: 'POST',
        path: '/payments',
        statusCode: 402,
        message: 'Pago rechazado',
      ),
    ]);

    await expectLater(
      PaymentsRepository(api.client).charge(
        const PaymentRequest(
          cardNumber: ApiConfig.testCardDeclined,
          cardName: 'Juan Pérez',
          expiry: '12/30',
          cvv: '123',
        ),
      ),
      throwsA(isA<ApiException>()
          .having((e) => e.kind, 'kind', ApiErrorKind.paymentRequired)),
    );
  });

  test('GET /me/payments devuelve el historial', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'GET',
        path: '/me/payments',
        data: <dynamic>[
          <String, dynamic>{'id': 'pay_1', 'amount': 1, 'currency': 'USD'},
        ],
      ),
    ]);

    final payments = await PaymentsRepository(api.client).mine();

    expect(payments, hasLength(1));
    expect(payments.first.amount, 1.0);
  });
}
