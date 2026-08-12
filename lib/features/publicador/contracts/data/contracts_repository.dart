import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../shared/models/contract.dart';

class ContractsRepository {
  ContractsRepository(this._client);

  final ApiClient _client;

  /// GET /me/contracts?status= — contratos donde soy contratante o contratado.
  Future<List<Contract>> mine({String? status}) => _client.get<List<Contract>>(
        '/me/contracts',
        query: <String, dynamic>{'status': status},
        parse: (data) => asModelList(data, Contract.fromJson),
      );

  /// GET /contracts/{id}
  Future<Contract> detail(String id) => _client.get<Contract>(
        '/contracts/$id',
        parse: (data) => Contract.fromJson(asMap(data)),
      );
}

final contractsRepositoryProvider = Provider<ContractsRepository>(
  (ref) => ContractsRepository(ref.watch(apiClientProvider)),
);
