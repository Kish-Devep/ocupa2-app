import '../../core/network/json.dart';

enum ContractStatus {
  pending,
  active,
  rejected,
  cancelled;

  static ContractStatus parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'active':
        return ContractStatus.active;
      case 'rejected':
        return ContractStatus.rejected;
      case 'cancelled':
      case 'canceled':
        return ContractStatus.cancelled;
      case 'pending':
      default:
        return ContractStatus.pending;
    }
  }

  String get label => switch (this) {
        ContractStatus.pending => 'Pendiente',
        ContractStatus.active => 'Activo',
        ContractStatus.rejected => 'Rechazado',
        ContractStatus.cancelled => 'Cancelado',
      };
}

class ContractParty {
  const ContractParty({required this.id, this.nombre, this.email});

  final String id;
  final String? nombre;
  final String? email;

  static ContractParty? fromJson(dynamic value) {
    if (value is! Map) return null;
    final json = asMap(value);
    return ContractParty(
      id: asString(json['id']),
      nombre: asStringOrNull(json['nombre']),
      email: asStringOrNull(json['email']),
    );
  }
}

class ContractComment {
  const ContractComment({
    required this.by,
    required this.body,
    required this.createdAt,
  });

  final ContractParty? by;
  final String body;
  final DateTime? createdAt;

  factory ContractComment.fromJson(JsonMap json) => ContractComment(
        by: ContractParty.fromJson(json['by']),
        body: asString(json['body']),
        createdAt: asDate(json['createdAt']),
      );
}

class ContractPhoto {
  const ContractPhoto({
    required this.by,
    required this.url,
    required this.description,
    required this.createdAt,
  });

  final ContractParty? by;
  final String url;
  final String description;
  final DateTime? createdAt;

  factory ContractPhoto.fromJson(JsonMap json) => ContractPhoto(
        by: ContractParty.fromJson(json['by']),
        url: asString(json['url']),
        description: asString(json['description']),
        createdAt: asDate(json['createdAt']),
      );
}

class Contract {
  const Contract({
    required this.id,
    required this.status,
    this.offerId,
    this.jobTypeName,
    this.contratante,
    this.contratado,
    this.myRole,
    this.salary,
    this.currency,
    this.startDate,
    this.duration,
    this.createdAt,
    this.acceptedAt,
    this.cancelJustification,
    this.cancelledBy,
    this.cancelledAt,
    this.comments = const <ContractComment>[],
    this.photos = const <ContractPhoto>[],
  });

  final String id;
  final ContractStatus status;
  final String? offerId;
  final String? jobTypeName;
  final ContractParty? contratante;
  final ContractParty? contratado;
  final String? myRole;
  final double? salary;
  final String? currency;
  final DateTime? startDate;
  final String? duration;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final String? cancelJustification;
  final ContractParty? cancelledBy;
  final DateTime? cancelledAt;
  final List<ContractComment> comments;
  final List<ContractPhoto> photos;

  factory Contract.fromJson(JsonMap json) => Contract(
        id: asString(pick(json, ['id', '_id'])),
        status: ContractStatus.parse(asStringOrNull(json['status'])),
        offerId: asStringOrNull(json['offerId']),
        jobTypeName: asStringOrNull(json['jobTypeName']),
        contratante: ContractParty.fromJson(json['contratante']),
        contratado: ContractParty.fromJson(json['contratado']),
        myRole: asStringOrNull(json['myRole']),
        salary: asDouble(json['salary']),
        currency: asStringOrNull(json['currency']),
        startDate: asDate(json['startDate']),
        duration: asStringOrNull(json['duration']),
        createdAt: asDate(json['createdAt']),
        acceptedAt: asDate(json['acceptedAt']),
        cancelJustification: asStringOrNull(json['cancelJustification']),
        cancelledBy: ContractParty.fromJson(json['cancelledBy']),
        cancelledAt: asDate(json['cancelledAt']),
        comments: asModelList(json['comments'], ContractComment.fromJson),
        photos: asModelList(json['photos'], ContractPhoto.fromJson),
      );

  bool get soyContratante => myRole == 'contratante';
  bool get soyContratado => myRole == 'contratado';
}