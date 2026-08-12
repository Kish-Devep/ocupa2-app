import 'package:flutter/material.dart';

import '../../models/custom_field.dart';
import 'dynamic_field_validators.dart';
import 'dynamic_field_widget.dart';

/// Controlador del formulario dinámico. Se instancia fuera del widget para que
/// la pantalla anfitriona pueda leer y validar los valores al enviar.
class DynamicFormController extends ChangeNotifier {
  DynamicFormController({
    List<CustomField> fields = const <CustomField>[],
    Map<String, dynamic>? initialValues,
  })  : _fields = List<CustomField>.from(fields),
        _values = Map<String, dynamic>.from(initialValues ?? const {});

  List<CustomField> _fields;
  final Map<String, dynamic> _values;
  Map<String, String> _errors = <String, String>{};

  List<CustomField> get fields => List.unmodifiable(_fields);
  Map<String, String> get errors => Map.unmodifiable(_errors);
  Map<String, dynamic> get rawValues => Map.unmodifiable(_values);

  void setFields(List<CustomField> fields) {
    _fields = List<CustomField>.from(fields);
    _values.removeWhere((key, _) => !_fields.any((f) => f.key == key));
    notifyListeners();
  }

  dynamic valueOf(String key) => _values[key];

  void setValue(String key, dynamic value) {
    _values[key] = value;
    if (_errors.containsKey(key)) {
      _errors = Map<String, String>.from(_errors)..remove(key);
    }
    notifyListeners();
  }

  /// `true` si todo es válido. Si no, publica los errores y refresca la UI.
  bool validate() {
    _errors = DynamicFieldValidators.validateAll(_fields, _values);
    notifyListeners();
    return _errors.isEmpty;
  }

  /// Valores normalizados listos para el API, en forma de mapa
  /// (`customAnswers` de OfferInput).
  Map<String, dynamic> toAnswersMap() {
    final result = <String, dynamic>{};
    for (final field in _fields) {
      final value = DynamicFieldValidators.serialize(field, _values[field.key]);
      if (value == null) continue;
      if (value is String && value.isEmpty) continue;
      result[field.key] = value;
    }
    return result;
  }

  /// Valores normalizados en forma de lista `[{questionId, value}]`
  /// (`answers` de POST /offers/{id}/apply).
  List<Map<String, dynamic>> toAnswersList() {
    final result = <Map<String, dynamic>>[];
    for (final field in _fields) {
      final value = DynamicFieldValidators.serialize(field, _values[field.key]);
      if (value == null) continue;
      if (value is String && value.isEmpty) continue;
      result.add(<String, dynamic>{'questionId': field.key, 'value': value});
    }
    return result;
  }
}

/// Widget genérico y reutilizable. Se usa SIN MODIFICAR en:
///  - `features/aplicante/offer_detail` → preguntas de la oferta
///  - `features/publicador/publish_offer` → campos del tipo de empleo
class DynamicForm extends StatelessWidget {
  const DynamicForm({
    super.key,
    required this.controller,
    this.enabled = true,
    this.emptyPlaceholder,
  });

  final DynamicFormController controller;
  final bool enabled;
  final Widget? emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final fields = controller.fields;
        if (fields.isEmpty) {
          return emptyPlaceholder ?? const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final field in fields)
              DynamicFieldWidget(
                field: field,
                value: controller.valueOf(field.key),
                errorText: controller.errors[field.key],
                enabled: enabled,
                onChanged: (value) => controller.setValue(field.key, value),
              ),
          ],
        );
      },
    );
  }
}
