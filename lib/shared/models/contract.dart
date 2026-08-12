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
  });

  final String id;
  final ContractStatus status;
  final String? offerId;
  final String? jobTypeName;
  final ContractParty? contratante;
  final ContractParty? contratado;
  final String? myRole; // contratante | contratado
  final double? salary;
  final String? currency;
  final DateTime? startDate;
  final String? duration;
  final DateTime? createdAt;
  final DateTime? acceptedAt;

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
      );

  bool get soyContratante => myRole == 'contratante';
}
