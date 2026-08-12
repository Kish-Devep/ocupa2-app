import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/date_formats.dart';
import '../../../../../shared/models/application.dart';
import '../../../../../shared/widgets/status_badge.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.application, this.onTap});

  final Application application;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final offer = application.offer;
    final isWinner = application.status == ApplicationStatus.winner;
    final isDiscarded = application.status == ApplicationStatus.discarded;

    return Opacity(
      opacity: isDiscarded ? 0.75 : 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: isWinner ? AppColors.statusWinnerFg : AppColors.outlineVariant,
            width: isWinner ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isWinner
                        ? AppColors.statusWinnerBg
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                  child: Icon(
                    switch (application.status) {
                      ApplicationStatus.winner => Icons.verified_outlined,
                      ApplicationStatus.discarded => Icons.cancel_outlined,
                      _ => Icons.business_center_outlined,
                    },
                    color: isWinner ? AppColors.statusWinnerFg : AppColors.outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              offer?.displayTitle ?? 'Oferta',
                              style: AppTypography.labelLg,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          StatusBadge(status: application.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.outline),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              offer?.address ?? 'Ubicación no disponible',
                              style: AppTypography.labelMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isWinner
                            ? '¡Fuiste seleccionado! Revisa tus contratos.'
                            : 'Aplicaste ${DateFormats.relative(application.createdAt)}',
                        style: AppTypography.labelMd.copyWith(
                          color: isWinner
                              ? AppColors.statusWinnerFg
                              : AppColors.outline,
                          fontWeight: isWinner ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
