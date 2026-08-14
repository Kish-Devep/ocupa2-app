import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/json.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/models/contract.dart';

class ContractsRepository {
  ContractsRepository(this._client);

  final ApiClient _client;

  Future<List<Contract>> mine({String? status}) => _client.get<List<Contract>>(
        '/me/contracts',
        query: <String, dynamic>{'status': status},
        parse: (data) => asModelList(data, Contract.fromJson),
      );

  Future<Contract> detail(String id) => _client.get<Contract>(
        '/contracts/$id',
        parse: (data) => Contract.fromJson(asMap(data)),
      );

  Future<Contract> updateTerms(
    String id, {
    required double salary,
    required String currency,
    required DateTime startDate,
    required String duration,
  }) =>
      _client.put<Contract>(
        '/contracts/$id/terms',
        body: <String, dynamic>{
          'salary': salary,
          'currency': currency,
          'startDate': DateFormats.apiDate(startDate),
          'duration': duration.trim(),
        },
        parse: (data) => Contract.fromJson(asMap(data)),
      );

  Future<Contract> accept(String id) => _client.post<Contract>(
        '/contracts/$id/accept',
        parse: (data) => Contract.fromJson(asMap(data)),
      );

  Future<Contract> reject(String id) => _client.post<Contract>(
        '/contracts/$id/reject',
        parse: (data) => Contract.fromJson(asMap(data)),
      );

  Future<ContractComment> addComment({
    required String id,
    required String body,
  }) =>
      _client.post<ContractComment>(
        '/contracts/$id/comments',
        body: <String, dynamic>{'body': body.trim()},
        parse: (data) => ContractComment.fromJson(asMap(data)),
      );

  Future<ContractPhoto> addPhoto({
    required String id,
    required String photo,
    required String description,
  }) =>
      _client.post<ContractPhoto>(
        '/contracts/$id/photos',
        body: <String, dynamic>{
          'photo': photo,
          'description': description.trim(),
        },
        parse: (data) => ContractPhoto.fromJson(asMap(data)),
      );

  Future<Contract> cancel({
    required String id,
    required String justification,
  }) =>
      _client.post<Contract>(
        '/contracts/$id/cancel',
        body: <String, dynamic>{'justification': justification.trim()},
        parse: (data) => Contract.fromJson(asMap(data)),
      );
}

final contractsRepositoryProvider = Provider<ContractsRepository>(
  (ref) => ContractsRepository(ref.watch(apiClientProvider)),
);