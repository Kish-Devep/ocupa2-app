import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/contract.dart';
import '../data/contracts_repository.dart';

final contractsStatusFilterProvider = StateProvider<String?>((ref) => null);

final myContractsProvider = FutureProvider<List<Contract>>(
  (ref) => ref.watch(contractsRepositoryProvider).mine(
        status: ref.watch(contractsStatusFilterProvider),
      ),
);
