import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../models/application.dart';

/// Badge pill de estado, con la semántica de color del design system:
/// ámbar = en revisión, gris = descartado, azul = finalista, verde = ganador.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status})
      : _label = null,
        _background = null,
        _foreground = null;

  const StatusBadge.custom({
    super.key,
    required String label,
    required Color background,
    required Color foreground,
  })  : status = null,
        _label = label,
        _background = background,
        _foreground = foreground;

  final ApplicationStatus? status;
  final String? _label;
  final Color? _background;
  final Color? _foreground;

  String get label => _label ?? status?.label ?? '';

  Color get background {
    if (_background != null) return _background;
    return switch (status) {
      ApplicationStatus.applied => AppColors.statusReviewBg,
      ApplicationStatus.discarded => AppColors.statusDiscardedBg,
      ApplicationStatus.finalist => AppColors.statusFinalistBg,
      ApplicationStatus.winner => AppColors.statusWinnerBg,
      null => AppColors.surfaceContainerHigh,
    };
  }

  Color get foreground {
    if (_foreground != null) return _foreground;
    return switch (status) {
      ApplicationStatus.applied => AppColors.statusReviewFg,
      ApplicationStatus.discarded => AppColors.statusDiscardedFg,
      ApplicationStatus.finalist => AppColors.statusFinalistFg,
      ApplicationStatus.winner => AppColors.statusWinnerFg,
      null => AppColors.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
