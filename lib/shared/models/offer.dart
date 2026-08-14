import '../../core/network/json.dart';
import 'custom_field.dart';
import 'geo_point.dart';
import 'user.dart';

enum OfferStatus {
  published,
  inactive,
  closed;

  static OfferStatus parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'inactive':
        return OfferStatus.inactive;
      case 'closed':
        return OfferStatus.closed;
      case 'published':
      default:
        return OfferStatus.published;
    }
  }

  String get apiValue => name;

  String get label => switch (this) {
        OfferStatus.published => 'Activa',
        OfferStatus.inactive => 'Desactivada',
        OfferStatus.closed => 'Cerrada',
      };

  bool get isPublished => this == OfferStatus.published;
}

enum ContractType {
  temporal,
  fijo,
  horas;

  static ContractType? parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'temporal':
        return ContractType.temporal;
      case 'fijo':
        return ContractType.fijo;
      case 'horas':
        return ContractType.horas;
      default:
        return null;
    }
  }

  String get apiValue => name;

  String get label => switch (this) {
        ContractType.temporal => 'Temporal',
        ContractType.fijo => 'Fijo',
        ContractType.horas => 'Por horas',
      };
}

class OfferPayment {
  const OfferPayment({this.amount, this.currency});

  final double? amount;
  final String? currency;

  factory OfferPayment.fromJson(dynamic value) {
    final json = asMap(value);
    return OfferPayment(
      amount: asDouble(json['amount']),
      currency: asStringOrNull(json['currency']),
    );
  }

  JsonMap toJson() => <String, dynamic>{
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency,
      };
}

/// Pregunta dinámica asociada a una oferta (`questions` en la respuesta).
class OfferQuestion {
  const OfferQuestion({
    required this.id,
    required this.field,
  });

  final String id;
  final CustomField field;

  factory OfferQuestion.fromJson(JsonMap json) {
    final field = CustomField.fromJson(json);
    return OfferQuestion(
      id: asString(
        pick(json, ['id', '_id', 'questionId', 'key']),
        fallback: field.key,
      ),
      field: field,
    );
  }
}

class Offer {
  const Offer({
    required this.id,
    required this.jobTypeKey,
    required this.contractType,
    required this.description,
    required this.address,
    this.jobTypeName,
    this.photo,
    this.location,
    this.payment,
    this.deadline,
    this.customAnswers = const <String, dynamic>{},
    this.questions = const <OfferQuestion>[],
    this.status = OfferStatus.published,
    this.createdAt,
    this.likesCount = 0,
    this.likedByMe = false, // <-- Cambiado de `liked` a `likedByMe`
    this.applicantsCount = 0,
    this.publisher,
    this.myApplicationStatus,
  });

  final String id;
  final String jobTypeKey;
  final String? jobTypeName;
  final ContractType? contractType;
  final String description;
  final String address;
  final String? photo;
  final GeoPoint? location;
  final OfferPayment? payment;
  final DateTime? deadline;
  final Map<String, dynamic> customAnswers;
  final List<OfferQuestion> questions;
  final OfferStatus status;
  final DateTime? createdAt;
  final int likesCount;
  final bool likedByMe; // <-- Cambiado de `liked` a `likedByMe`
  final int applicantsCount;

  /// Solo llega poblado cuando el usuario autenticado es el ganador.
  /// El API se encarga de ocultarlo; la app simplemente respeta el nulo.
  final User? publisher;

  final String? myApplicationStatus;

  /// Permite crear copias modificadas de la oferta para actualizaciones optimistas en la UI
  Offer copyWith({
    String? id,
    String? jobTypeKey,
    String? jobTypeName,
    ContractType? contractType,
    String? description,
    String? address,
    String? photo,
    GeoPoint? location,
    OfferPayment? payment,
    DateTime? deadline,
    Map<String, dynamic>? customAnswers,
    List<OfferQuestion>? questions,
    OfferStatus? status,
    DateTime? createdAt,
    int? likesCount,
    bool? likedByMe,
    int? applicantsCount,
    User? publisher,
    String? myApplicationStatus,
  }) {
    return Offer(
      id: id ?? this.id,
      jobTypeKey: jobTypeKey ?? this.jobTypeKey,
      jobTypeName: jobTypeName ?? this.jobTypeName,
      contractType: contractType ?? this.contractType,
      description: description ?? this.description,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      location: location ?? this.location,
      payment: payment ?? this.payment,
      deadline: deadline ?? this.deadline,
      customAnswers: customAnswers ?? this.customAnswers,
      questions: questions ?? this.questions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      likedByMe: likedByMe ?? this.likedByMe,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      publisher: publisher ?? this.publisher,
      myApplicationStatus: myApplicationStatus ?? this.myApplicationStatus,
    );
  }

  factory Offer.fromJson(JsonMap json) {
    final publisherJson = pick(json, ['publisher', 'owner', 'publicante', 'user']);
    return Offer(
      id: asString(pick(json, ['id', '_id', 'offerId'])),
      jobTypeKey: asString(pick(json, ['jobTypeKey', 'jobType', 'key'])),
      jobTypeName: asStringOrNull(pick(json, ['jobTypeName', 'jobTypeLabel', 'title'])),
      contractType: ContractType.parse(asStringOrNull(json['contractType'])),
      description: asString(json['description']),
      address: asString(json['address']),
      photo: asStringOrNull(pick(json, ['photo', 'image', 'photoUrl'])),
      location: GeoPoint.fromJson(json['location']),
      payment: json['payment'] == null ? null : OfferPayment.fromJson(json['payment']),
      deadline: asDate(json['deadline']),
      customAnswers: asMap(json['customAnswers']),
      questions: asModelList(json['questions'], OfferQuestion.fromJson),
      status: OfferStatus.parse(asStringOrNull(json['status'])),
      createdAt: asDate(json['createdAt']),
      likesCount: asInt(pick(json, ['likes', 'likesCount'])) ?? 0,
      likedByMe: asBool(pick(json, ['liked', 'likedByMe'])), // <-- Asigna a likedByMe
      applicantsCount: asInt(
        pick(json, ['applicantsCount', 'applicationsCount', 'applicants', 'totalApplications']),
      ) ?? 0,
      publisher: publisherJson is Map ? User.fromJson(asMap(publisherJson)) : null,
      myApplicationStatus: asStringOrNull(
        pick(json, ['myApplicationStatus', 'applicationStatus']),
      ),
    );
  }

  /// El schema no tiene campo `title`: el encabezado se deriva del tipo de
  /// empleo, con la descripción como respaldo.
  String get displayTitle {
    final name = jobTypeName?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (jobTypeKey.isNotEmpty) {
      return jobTypeKey[0].toUpperCase() + jobTypeKey.substring(1);
    }
    return description.length > 40 ? '${description.substring(0, 40)}…' : description;
  }

  bool get hasLocation => location != null;

  bool get isPublished => status.isPublished;
}