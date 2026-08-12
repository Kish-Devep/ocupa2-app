import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/models/payment.dart';
import 'payment_request.dart';

class PaymentsRepository {
  PaymentsRepository(this._client);

  final ApiClient _client;

  /// POST /payments — cobro simulado de 1 USD.
  /// 201 pago aprobado (devuelve el `id` que se usa como `paymentId`).
  /// 402 pago rechazado.
  Future<Payment> charge(PaymentRequest request) => _client.post<Payment>(
        '/payments',
        body: request.toJson(),
        parse: (data) => Payment.fromJson(asMap(data)),
      );

  /// GET /me/payments — módulo 16.
  Future<List<Payment>> mine() => _client.get<List<Payment>>(
        '/me/payments',
        parse: (data) => asModelList(data, Payment.fromJson),
      );
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepository(ref.watch(apiClientProvider)),
);
