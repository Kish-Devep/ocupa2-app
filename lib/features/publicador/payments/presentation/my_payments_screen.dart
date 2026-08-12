import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../state/my_payments_controller.dart';

class MyPaymentsScreen extends ConsumerWidget {
  const MyPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(myPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis pagos'),
      ),
      body: AsyncView(
        value: payments,
        onRetry: () => ref.invalidate(myPaymentsProvider),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'Sin pagos registrados',
              message: 'Aquí verás el historial de tus publicaciones pagadas.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myPaymentsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final payment = items[index];
                final approved = payment.isApproved;
                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: approved
                            ? AppColors.statusWinnerBg
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      child: Icon(
                        approved ? Icons.check_circle_outline : Icons.error_outline,
                        color: approved
                            ? AppColors.statusWinnerFg
                            : AppColors.onErrorContainer,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      DateFormats.money(payment.amount, payment.currency),
                      style: AppTypography.labelLg,
                    ),
                    subtitle: Text(
                      '${DateFormats.short(payment.createdAt)}'
                      '${payment.cardLast4 == null ? '' : ' · ****${payment.cardLast4}'}',
                      style: AppTypography.labelMd,
                    ),
                    trailing: Text(
                      approved ? 'Aprobado' : (payment.status ?? 'Rechazado'),
                      style: AppTypography.labelMd.copyWith(
                        color: approved
                            ? AppColors.statusWinnerFg
                            : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
