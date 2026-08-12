import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/payment.dart';
import '../data/payments_repository.dart';

final myPaymentsProvider = FutureProvider.autoDispose<List<Payment>>(
  (ref) => ref.watch(paymentsRepositoryProvider).mine(),
);
