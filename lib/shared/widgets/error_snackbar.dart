import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Traduce cualquier error a un SnackBar legible. Los códigos documentados
/// (401/402/403/409/422/502) ya vienen con mensaje en `ApiException`.
void showErrorSnack(BuildContext context, Object error) {
  final message =
      error is ApiException ? error.message : 'Ocurrió un error inesperado.';
  _show(context, message, AppColors.error);
}

void showSuccessSnack(BuildContext context, String message) {
  _show(context, message, AppColors.primaryContainer);
}

void _show(BuildContext context, String message, Color background) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
    );
}
