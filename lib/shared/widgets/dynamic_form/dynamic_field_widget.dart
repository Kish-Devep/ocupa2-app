import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formats.dart';
import '../../models/custom_field.dart';

/// Renderiza UN campo según su `type`. El renderizado condicional que se prueba
/// en `dynamic_form_render_test.dart` vive aquí.
class DynamicFieldWidget extends StatelessWidget {
  const DynamicFieldWidget({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final CustomField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case CustomFieldType.check:
        return _buildCheck(context);
      case CustomFieldType.select:
        return _buildLabeled(child: _buildSelect(context));
      case CustomFieldType.date:
        return _buildLabeled(child: _buildDate(context));
      case CustomFieldType.number:
        return _buildLabeled(child: _buildText(context, numeric: true));
      case CustomFieldType.text:
        return _buildLabeled(child: _buildText(context, numeric: false));
    }
  }

  Widget _buildLabeled({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: field.label,
              style: AppTypography.labelLg,
              children: [
                if (field.required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          child,
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context, {required bool numeric}) {
    return TextFormField(
      key: ValueKey('dynamic_field_${field.key}'),
      initialValue: value?.toString() ?? '',
      enabled: enabled,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: numeric
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ]
          : null,
      maxLines: numeric ? 1 : null,
      minLines: 1,
      decoration: InputDecoration(
        hintText: numeric ? 'Ej. 3' : 'Escribe tu respuesta',
        errorText: errorText,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildSelect(BuildContext context) {
    final current = value?.toString();
    final options = field.options;
    return DropdownButtonFormField<String>(
      key: ValueKey('dynamic_field_${field.key}'),
      value: options.contains(current) ? current : null,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Selecciona una opción',
        errorText: errorText,
      ),
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: AppTypography.bodyLg),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildDate(BuildContext context) {
    final selected = value is DateTime
        ? value as DateTime
        : DateTime.tryParse(value?.toString() ?? '');
    return InkWell(
      key: ValueKey('dynamic_field_${field.key}'),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      onTap: enabled
          ? () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: selected ?? now,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 5),
                locale: const Locale('es'),
              );
              if (picked != null) onChanged(picked);
            }
          : null,
      child: InputDecorator(
        decoration: InputDecoration(errorText: errorText),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected == null ? 'Selecciona una fecha' : DateFormats.short(selected),
                style: selected == null
                    ? const TextStyle(color: AppColors.outline)
                    : AppTypography.bodyLg,
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 20, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildCheck(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: errorText == null
                    ? AppColors.outlineVariant
                    : AppColors.error,
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                key: ValueKey('dynamic_field_${field.key}'),
                value: value == true,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                title: Text(
                  field.required ? '${field.label} *' : field.label,
                  style: AppTypography.bodyLg,
                ),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, top: AppSpacing.base),
              child: Text(
                errorText!,
                style: AppTypography.labelMd.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}
