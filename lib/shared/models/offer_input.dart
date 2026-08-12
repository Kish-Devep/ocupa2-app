import '../../core/network/json.dart';
import '../../core/utils/date_formats.dart';
import 'custom_field.dart';
import 'geo_point.dart';
import 'offer.dart';

/// Pregunta que el publicador define para su oferta.
/// Schema: `{label, type ∈ (text|date|select|check), required, options}`.
class OfferQuestionInput {
  const OfferQuestionInput({
    required this.label,
    required this.type,
    this.required = false,
    this.options = const <String>[],
  });

  final String label;
  final CustomFieldType type;
  final bool required;
  final List<String> options;

  JsonMap toJson() => <String, dynamic>{
        'label': label,
        'type': type.apiValue,
        'required': required,
        if (options.isNotEmpty) 'options': options,
      };

  OfferQuestionInput copyWith({
    String? label,
    CustomFieldType? type,
    bool? required,
    List<String>? options,
  }) =>
      OfferQuestionInput(
        label: label ?? this.label,
        type: type ?? this.type,
        required: required ?? this.required,
        options: options ?? this.options,
      );
}

/// Schema `OfferInput` — 1:1 con el spec OpenAPI. Nada más, nada menos.
class OfferInput {
  const OfferInput({
    required this.jobTypeKey,
    required this.contractType,
    required this.description,
    required this.address,
    required this.photo,
    required this.paymentId,
    required this.payment,
    this.location,
    this.deadline,
    this.customAnswers,
    this.questions,
  });

  final String jobTypeKey; // requerido
  final ContractType contractType; // requerido
  final String description; // requerido
  final String address; // requerido
  final String photo; // requerido — URL devuelta por /uploads
  final String paymentId; // requerido — id de /payments aprobado
  final OfferPayment payment; // requerido
  final GeoPoint? location;
  final DateTime? deadline;
  final Map<String, dynamic>? customAnswers;
  final List<OfferQuestionInput>? questions;

  JsonMap toJson() => <String, dynamic>{
        'jobTypeKey': jobTypeKey,
        'contractType': contractType.apiValue,
        'description': description,
        'address': address,
        'photo': photo,
        'paymentId': paymentId,
        'payment': payment.toJson(),
        if (location != null) 'location': location!.toJson(),
        if (deadline != null) 'deadline': DateFormats.apiDate(deadline!),
        if (customAnswers != null && customAnswers!.isNotEmpty)
          'customAnswers': customAnswers,
        if (questions != null && questions!.isNotEmpty)
          'questions': questions!.map((q) => q.toJson()).toList(),
      };
}
