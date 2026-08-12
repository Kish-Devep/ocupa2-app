import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/features/publicador/contracts/data/contracts_repository.dart';
import 'package:ocupa2/shared/models/contract.dart';

import '../helpers/mocks.dart';

void main() {
  test('GET /me/contracts parsea myRole, status y las partes', () async {
    final api = TestApi.build([
      FakeRoute.ok(
        method: 'GET',
        path: '/me/contracts',
        data: <dynamic>[
          <String, dynamic>{
            'id': 'c1',
            'offerId': 'o1',
            'jobTypeName': 'Chofer',
            'myRole': 'contratante',
            'status': 'pending',
            'salary': 25000,
            'currency': 'DOP',
            'duration': '3 meses',
            'contratado': <String, dynamic>{'id': 'u2', 'nombre': 'Ana Gómez'},
          },
        ],
      ),
    ]);

    final contracts = await ContractsRepository(api.client).mine();

    expect(contracts, hasLength(1));
    expect(contracts.first.status, ContractStatus.pending);
    expect(contracts.first.soyContratante, isTrue);
    expect(contracts.first.contratado?.nombre, 'Ana Gómez');
  });

  test('GET /me/contracts?status= filtra por estado', () async {
    final api = TestApi.build([
      FakeRoute.ok(method: 'GET', path: '/me/contracts', data: <dynamic>[]),
    ]);

    await ContractsRepository(api.client).mine(status: 'active');

    expect(api.adapter.lastRequest.queryParameters['status'], 'active');
  });
}
