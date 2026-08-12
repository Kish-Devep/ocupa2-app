import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/models/contract.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../state/my_contracts_controller.dart';

/// Extra del mandato: se crea automáticamente al marcar status = winner.
class MyContractsScreen extends ConsumerWidget {
  const MyContractsScreen({super.key});

  static const Map<ContractStatus, (Color, Color)> _colors = {
    ContractStatus.pending: (AppColors.statusReviewBg, AppColors.statusReviewFg),
    ContractStatus.active: (AppColors.statusWinnerBg, AppColors.statusWinnerFg),
    ContractStatus.rejected: (AppColors.errorContainer, AppColors.onErrorContainer),
    ContractStatus.cancelled:
        (AppColors.surfaceContainerHighest, AppColors.onSurfaceVariant),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(myContractsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Mis contratos'),
      ),
      body: AsyncView(
        value: contracts,
        onRetry: () => ref.invalidate(myContractsProvider),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.handshake_outlined,
              title: 'Sin contratos',
              message: 'Los contratos se crean automáticamente cuando eliges '
                  'un ganador o cuando te eligen a ti.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myContractsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final contract = items[index];
                final palette = _colors[contract.status]!;
                final counterpart = contract.soyContratante
                    ? contract.contratado
                    : contract.contratante;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contract.jobTypeName ?? 'Contrato',
                                style: AppTypography.labelLg,
                              ),
                            ),
                            StatusBadge.custom(
                              label: contract.status.label,
                              background: palette.$1,
                              foreground: palette.$2,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          contract.soyContratante
                              ? 'Contrataste a ${counterpart?.nombre ?? "—"}'
                              : 'Te contrató ${counterpart?.nombre ?? "—"}',
                          style: AppTypography.bodyMd,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.base,
                          children: [
                            if (contract.salary != null)
                              Text(
                                DateFormats.money(
                                  contract.salary,
                                  contract.currency,
                                ),
                                style: AppTypography.labelLg
                                    .copyWith(color: AppColors.primary),
                              ),
                            if (contract.startDate != null)
                              Text('Inicio: ${DateFormats.short(contract.startDate)}',
                                  style: AppTypography.labelMd),
                            if (contract.duration != null)
                              Text('Duración: ${contract.duration}',
                                  style: AppTypography.labelMd),
                          ],
                        ),
                      ],
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
