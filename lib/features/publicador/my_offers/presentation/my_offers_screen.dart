import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/offer_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../state/my_offers_controller.dart';

/// Módulo 15 — GET /me/offers con acciones de dueño.
class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    String offerId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desactivar oferta'),
        content: const Text(
          'Dejará de aparecer en el listado público y no admitirá nuevas '
          'aplicaciones. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(myOffersControllerProvider.notifier).deactivate(offerId);
      if (context.mounted) showSuccessSnack(context, 'Oferta desactivada.');
    } catch (error) {
      if (context.mounted) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(myOffersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis ofertas')),
      body: AsyncView(
        value: offers,
        onRetry: () => ref.invalidate(myOffersControllerProvider),
        data: (items) {
          if (items.isEmpty) {
            return EmptyView(
              icon: Icons.campaign_outlined,
              title: 'Todavía no publicaste ninguna oferta',
              message: 'Publica una oferta por 1 USD y empieza a recibir '
                  'aplicantes hoy mismo.',
              action: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.publish),
                icon: const Icon(Icons.add),
                label: const Text('Publicar oferta'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(myOffersControllerProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                AppSpacing.containerMargin,
                AppSpacing.containerMargin,
                96,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final offer = items[index];
                return OfferCard(
                  offer: offer,
                  onTap: () => context.push(AppRoutes.offerDetail(offer.id)),
                  footer: Column(
                    children: [
                      Row(
                        children: [
                          StatusBadge.custom(
                            label: offer.active ? 'Activa' : 'Desactivada',
                            background: offer.active
                                ? AppColors.statusWinnerBg
                                : AppColors.surfaceContainerHighest,
                            foreground: offer.active
                                ? AppColors.statusWinnerFg
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${offer.applicationsCount} '
                            '${offer.applicationsCount == 1 ? "aplicante" : "aplicantes"}',
                            style: AppTypography.labelMd,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => context.push(
                                AppRoutes.offerApplicants(offer.id),
                              ),
                              icon: const Icon(Icons.people_outline, size: 18),
                              label: const Text('Ver aplicantes'),
                            ),
                          ),
                          if (offer.active) ...[
                            const SizedBox(width: AppSpacing.xs),
                            IconButton(
                              tooltip: 'Desactivar',
                              icon: const Icon(Icons.visibility_off_outlined,
                                  color: AppColors.error),
                              onPressed: () =>
                                  _confirmDeactivate(context, ref, offer.id),
                            ),
                          ],
                        ],
                      ),
                    ],
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
