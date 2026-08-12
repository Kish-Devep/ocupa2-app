import '../../models/custom_field.dart';

/// Validación de campos dinámicos. Función pura, sin Flutter: es directamente
/// testeable (`dynamic_field_validators_test.dart`).
class DynamicFieldValidators {
  const DynamicFieldValidators._();

  static String? validate(CustomField field, dynamic value) {
    switch (field.type) {
      case CustomFieldType.check:
        // Una casilla requerida debe estar marcada.
        if (field.required && value != true) {
          return 'Debes marcar "${field.label}"';
        }
        return null;

      case CustomFieldType.number:
        final raw = value?.toString().trim() ?? '';
        if (raw.isEmpty) {
          return field.required ? '${field.label} es obligatorio' : null;
        }
        if (double.tryParse(raw.replaceAll(',', '')) == null) {
          return '${field.label} debe ser un número';
        }
        return null;

      case CustomFieldType.date:
        if (value == null) {
          return field.required ? '${field.label} es obligatorio' : null;
        }
        if (value is! DateTime && DateTime.tryParse(value.toString()) == null) {
          return 'Fecha no válida';
        }
        return null;

      case CustomFieldType.select:
        final raw = value?.toString().trim() ?? '';
        if (raw.isEmpty) {
          return field.required ? 'Selecciona una opción para ${field.label}' : null;
        }
        if (field.options.isNotEmpty && !field.options.contains(raw)) {
          return 'Opción no válida';
        }
        return null;

      case CustomFieldType.text:
        final raw = value?.toString().trim() ?? '';
        if (raw.isEmpty) {
          return field.required ? '${field.label} es obligatorio' : null;
        }
        return null;
    }
  }

  /// Valida el mapa completo y devuelve `{key: mensaje}` con los errores.
  static Map<String, String> validateAll(
    List<CustomField> fields,
    Map<String, dynamic> values,
  ) {
    final errors = <String, String>{};
    for (final field in fields) {
      final error = validate(field, values[field.key]);
      if (error != null) errors[field.key] = error;
    }
    return errors;
  }

  /// Normaliza los valores al tipo que espera el API antes de serializar.
  static dynamic serialize(CustomField field, dynamic value) {
    switch (field.type) {
      case CustomFieldType.number:
        final raw = value?.toString().replaceAll(',', '').trim() ?? '';
        if (raw.isEmpty) return null;
        return double.tryParse(raw);
      case CustomFieldType.date:
        if (value is DateTime) {
          return '${value.year.toString().padLeft(4, '0')}-'
              '${value.month.toString().padLeft(2, '0')}-'
              '${value.day.toString().padLeft(2, '0')}';
        }
        return value;
      case CustomFieldType.check:
        return value == true;
      case CustomFieldType.text:
      case CustomFieldType.select:
        final raw = value?.toString().trim() ?? '';
        return raw.isEmpty ? null : raw;
    }
  }
}
