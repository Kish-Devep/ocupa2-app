import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/shared/models/custom_field.dart';
import 'package:ocupa2/shared/widgets/dynamic_form/dynamic_field_validators.dart';

void main() {
  group('validate por tipo de campo', () {
    test('text requerido rechaza vacío y acepta contenido', () {
      const field = CustomField(
          key: 'k', label: 'Nombre', type: CustomFieldType.text, required: true);
      expect(DynamicFieldValidators.validate(field, ''), isNotNull);
      expect(DynamicFieldValidators.validate(field, '   '), isNotNull);
      expect(DynamicFieldValidators.validate(field, 'Juan'), isNull);
    });

    test('text opcional acepta vacío', () {
      const field = CustomField(key: 'k', label: 'Nota', type: CustomFieldType.text);
      expect(DynamicFieldValidators.validate(field, ''), isNull);
    });

    test('number rechaza texto no numérico', () {
      const field = CustomField(key: 'k', label: 'Años', type: CustomFieldType.number);
      expect(DynamicFieldValidators.validate(field, 'abc'), isNotNull);
      expect(DynamicFieldValidators.validate(field, '3.5'), isNull);
    });

    test('select rechaza una opción fuera de la lista', () {
      const field = CustomField(
        key: 'k',
        label: 'Turno',
        type: CustomFieldType.select,
        required: true,
        options: <String>['Mañana', 'Tarde'],
      );
      expect(DynamicFieldValidators.validate(field, 'Noche'), isNotNull);
      expect(DynamicFieldValidators.validate(field, 'Tarde'), isNull);
      expect(DynamicFieldValidators.validate(field, ''), isNotNull);
    });

    test('check requerido exige estar marcado', () {
      const field = CustomField(
          key: 'k', label: 'Acepto', type: CustomFieldType.check, required: true);
      expect(DynamicFieldValidators.validate(field, false), isNotNull);
      expect(DynamicFieldValidators.validate(field, null), isNotNull);
      expect(DynamicFieldValidators.validate(field, true), isNull);
    });

    test('date requerido exige una fecha', () {
      const field = CustomField(
          key: 'k', label: 'Inicio', type: CustomFieldType.date, required: true);
      expect(DynamicFieldValidators.validate(field, null), isNotNull);
      expect(DynamicFieldValidators.validate(field, DateTime(2026, 8, 30)), isNull);
    });
  });

  group('serialize — normalización para el API', () {
    test('date se serializa como YYYY-MM-DD', () {
      const field = CustomField(key: 'k', label: 'F', type: CustomFieldType.date);
      expect(
        DynamicFieldValidators.serialize(field, DateTime(2026, 8, 5)),
        '2026-08-05',
      );
    });

    test('number se serializa como num, no como String', () {
      const field = CustomField(key: 'k', label: 'N', type: CustomFieldType.number);
      expect(DynamicFieldValidators.serialize(field, '3'), 3.0);
    });

    test('check siempre devuelve bool', () {
      const field = CustomField(key: 'k', label: 'C', type: CustomFieldType.check);
      expect(DynamicFieldValidators.serialize(field, null), false);
      expect(DynamicFieldValidators.serialize(field, true), true);
    });
  });

  test('validateAll devuelve un error por cada campo inválido', () {
    const fields = <CustomField>[
      CustomField(key: 'a', label: 'A', type: CustomFieldType.text, required: true),
      CustomField(key: 'b', label: 'B', type: CustomFieldType.check, required: true),
      CustomField(key: 'c', label: 'C', type: CustomFieldType.text),
    ];
    final errors = DynamicFieldValidators.validateAll(
      fields,
      <String, dynamic>{'a': '', 'b': false},
    );
    expect(errors.keys, containsAll(<String>['a', 'b']));
    expect(errors.containsKey('c'), isFalse);
  });
}
