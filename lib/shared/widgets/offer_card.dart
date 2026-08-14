import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formats.dart';
import '../models/offer.dart';
import 'offer_like_button.dart';
import 'status_badge.dart';

/// Card de oferta usada en Explorar, Inicio y Mis ofertas.
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
    this.trailing,
    this.footer,
  });

  final Offer offer;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumb(url: offer.photo),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.displayTitle,
                          style: AppTypography.headlineSm,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                offer.address,
                                style: AppTypography.bodyMd,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (offer.applicantsCount > 0) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${offer.applicantsCount} ${offer.applicantsCount == 1 ? 'interesado' : 'interesados'}',
                                style: AppTypography.bodyMd,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (offer.contractType != null)
                    StatusBadge.custom(
                      label: offer.contractType!.label,
                      background: AppColors.secondaryContainer,
                      foreground: AppColors.onSecondaryContainer,
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pago estimado', style: AppTypography.labelMd),
                        Text(
                          DateFormats.money(
                            offer.payment?.amount,
                            offer.payment?.currency,
                          ),
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (offer.deadline != null)
                    Text(
                      'Hasta ${DateFormats.short(offer.deadline)}',
                      style: AppTypography.labelMd,
                    ),
                  const SizedBox(width: AppSpacing.xs),
                  OfferLikeButton(offer: offer),
                ],
              ),
              if (footer != null) ...[
                const SizedBox(height: AppSpacing.sm),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: SizedBox(
        width: 48,
        height: 48,
        child: url == null || url!.isEmpty
            ? Container(
                color: AppColors.surfaceContainer,
                child: const Icon(Icons.work_outline, color: AppColors.outline),
              )
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.surfaceContainer),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceContainer,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.outline,
                  ),
                ),
              ),
      ),
    );
  }
}