import '../../core/network/json.dart';

/// Schema `CustomField`. Los cinco tipos que el formulario dinámico renderiza.
enum CustomFieldType {
  text,
  number,
  date,
  select,
  check;

  static CustomFieldType parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'number':
      case 'numeric':
        return CustomFieldType.number;
      case 'date':
        return CustomFieldType.date;
      case 'select':
      case 'dropdown':
        return CustomFieldType.select;
      case 'check':
      case 'checkbox':
      case 'boolean':
        return CustomFieldType.check;
      case 'text':
      default:
        return CustomFieldType.text;
    }
  }

  String get apiValue => name;

  String get label => switch (this) {
        CustomFieldType.text => 'Texto',
        CustomFieldType.number => 'Número',
        CustomFieldType.date => 'Fecha',
        CustomFieldType.select => 'Selección',
        CustomFieldType.check => 'Casilla',
      };

  /// `OfferInput.questions[].type` NO admite `number`.
  static const List<CustomFieldType> allowedInOfferQuestions = [
    CustomFieldType.text,
    CustomFieldType.date,
    CustomFieldType.select,
    CustomFieldType.check,
  ];
}

class CustomField {
  const CustomField({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.options = const <String>[],
  });

  final String key;
  final String label;
  final CustomFieldType type;
  final bool required;
  final List<String> options;

  factory CustomField.fromJson(JsonMap json) {
    final label = asString(
      pick(json, ['label', 'name', 'title']),
      fallback: 'Campo',
    );
    return CustomField(
      key: asString(
        pick(json, ['key', 'id', '_id', 'questionId', 'name']),
        fallback: _slug(label),
      ),
      label: label,
      type: CustomFieldType.parse(asStringOrNull(json['type'])),
      required: asBool(pick(json, ['required', 'isRequired'])),
      options: asStringList(pick(json, ['options', 'choices', 'values'])),
    );
  }

  static String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  CustomField copyWith({
    String? key,
    String? label,
    CustomFieldType? type,
    bool? required,
    List<String>? options,
  }) =>
      CustomField(
        key: key ?? this.key,
        label: label ?? this.label,
        type: type ?? this.type,
        required: required ?? this.required,
        options: options ?? this.options,
      );

  JsonMap toJson() => <String, dynamic>{
        'label': label,
        'type': type.apiValue,
        'required': required,
        if (options.isNotEmpty) 'options': options,
      };
}
