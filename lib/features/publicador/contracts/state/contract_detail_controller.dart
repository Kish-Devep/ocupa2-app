import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/contract.dart';
import '../data/contracts_repository.dart';
import 'my_contracts_controller.dart';

class ContractDetailController
    extends AutoDisposeFamilyAsyncNotifier<Contract, String> {
  @override
  Future<Contract> build(String contractId) =>
      ref.watch(contractsRepositoryProvider).detail(contractId);

  Future<void> accept() async {
    await ref.read(contractsRepositoryProvider).accept(arg);
    ref.invalidate(myContractsProvider);
    ref.invalidateSelf();
  }

  Future<void> reject() async {
    await ref.read(contractsRepositoryProvider).reject(arg);
    ref.invalidate(myContractsProvider);
    ref.invalidateSelf();
  }

  Future<void> updateTerms({
    required double salary,
    required String currency,
    required DateTime startDate,
    required String duration,
  }) async {
    await ref.read(contractsRepositoryProvider).updateTerms(
          arg,
          salary: salary,
          currency: currency,
          startDate: startDate,
          duration: duration,
        );
    ref.invalidate(myContractsProvider);
    ref.invalidateSelf();
  }

  Future<void> addComment(String body) async {
    await ref.read(contractsRepositoryProvider).addComment(
          id: arg,
          body: body,
        );
    ref.invalidateSelf();
  }

  Future<void> addPhoto({
    required String photo,
    required String description,
  }) async {
    await ref.read(contractsRepositoryProvider).addPhoto(
          id: arg,
          photo: photo,
          description: description,
        );
    ref.invalidateSelf();
  }

  Future<void> cancel(String justification) async {
    await ref.read(contractsRepositoryProvider).cancel(
          id: arg,
          justification: justification,
        );
    ref.invalidate(myContractsProvider);
    ref.invalidateSelf();
  }
}

final contractDetailControllerProvider =
    AsyncNotifierProvider.autoDispose.family<
        ContractDetailController, Contract, String>(
  ContractDetailController.new,
);