import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/models/offer.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../state/offer_detail_controller.dart';
import 'apply_form_section.dart';

/// Módulo 6 — GET /offers/{id} + formulario de aplicación en la misma pantalla,
/// como en el mockup.
class OfferDetailScreen extends ConsumerWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(offerDetailProvider(offerId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ocupa2'),
      ),
      body: AsyncView(
        value: offer,
        onRetry: () => ref.invalidate(offerDetailProvider(offerId)),
        data: (offer) => ListView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          children: [
            if (offer.photo != null && offer.photo!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: CachedNetworkImage(
                  imageUrl: offer.photo!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color: AppColors.surfaceContainer,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.surfaceContainer,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(offer.displayTitle,
                              style: AppTypography.headlineSm),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.base,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXl),
                          ),
                          child: Text(
                            DateFormats.money(
                              offer.payment?.amount,
                              offer.payment?.currency,
                            ),
                            style: AppTypography.labelLg
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(offer.address, style: AppTypography.bodyMd),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.base,
                      children: [
                        if (offer.contractType != null)
                          StatusBadge.custom(
                            label: offer.contractType!.label,
                            background: AppColors.secondaryContainer,
                            foreground: AppColors.onSecondaryContainer,
                          ),
                        if (offer.deadline != null)
                          StatusBadge.custom(
                            label:
                                'Aplica hasta ${DateFormats.short(offer.deadline)}',
                            background: AppColors.tertiaryFixed,
                            foreground: AppColors.tertiary,
                          ),
                        if (!offer.active)
                          StatusBadge.custom(
                            label: 'Desactivada',
                            background: AppColors.errorContainer,
                            foreground: AppColors.onErrorContainer,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PublisherTile(offer: offer),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción del trabajo',
                        style: AppTypography.headlineSm),
                    const SizedBox(height: AppSpacing.xs),
                    Text(offer.description, style: AppTypography.bodyLg),
                    if (offer.customAnswers.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Detalles del puesto', style: AppTypography.labelLg),
                      const SizedBox(height: AppSpacing.xs),
                      for (final entry in offer.customAnswers.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.base),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(entry.key, style: AppTypography.bodyMd),
                              ),
                              Expanded(
                                child: Text(
                                  '${entry.value}',
                                  textAlign: TextAlign.right,
                                  style: AppTypography.labelLg,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (offer.active)
              ApplyFormSection(offer: offer)
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Esta oferta fue desactivada y ya no admite aplicaciones.',
                    style: AppTypography.bodyMd,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Requisito transversal: la identidad del publicante permanece OCULTA
/// salvo cuando el aplicante es el ganador. El API lo garantiza devolviendo
/// `publisher` nulo; la app solo refleja ese contrato.
class _PublisherTile extends StatelessWidget {
  const _PublisherTile({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final publisher = offer.publisher;
    final revealed = publisher != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: revealed
            ? AppColors.statusWinnerBg
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: revealed
                ? AppColors.statusWinnerFg
                : AppColors.surfaceContainerHighest,
            child: revealed
                ? Text(
                    publisher.initials,
                    style: AppTypography.labelMd.copyWith(color: Colors.white),
                  )
                : const Icon(Icons.person_outline,
                    color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  revealed ? publisher.displayName : 'Publicador anónimo',
                  style: AppTypography.labelLg,
                ),
                Text(
                  revealed
                      ? (publisher.email)
                      : 'Identidad oculta hasta la contratación',
                  style: AppTypography.labelMd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
