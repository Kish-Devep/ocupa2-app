import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Campo con etiqueta encima en `label-md` bold, como manda el design system.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.enabled = true,
    this.fieldKey,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final bool enabled;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelLg),
          const SizedBox(height: AppSpacing.base),
          TextFormField(
            key: fieldKey,
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            enabled: enabled,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            style: AppTypography.bodyLg,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffixIcon,
              hintStyle: const TextStyle(color: AppColors.outline),
            ),
          ),
        ],
      ),
    );
  }
}
