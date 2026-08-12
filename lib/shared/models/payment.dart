import '../../core/network/json.dart';

class Payment {
  const Payment({
    required this.id,
    this.amount,
    this.currency,
    this.status,
    this.cardLast4,
    this.brand,
    this.createdAt,
  });

  final String id;
  final double? amount;
  final String? currency;
  final String? status;
  final String? cardLast4;
  final String? brand;
  final DateTime? createdAt;

  factory Payment.fromJson(JsonMap json) => Payment(
        id: asString(pick(json, ['id', '_id', 'paymentId'])),
        amount: asDouble(json['amount']),
        currency: asStringOrNull(json['currency']),
        status: asStringOrNull(json['status']),
        cardLast4: asStringOrNull(pick(json, ['last4', 'cardLast4', 'card'])),
        brand: asStringOrNull(pick(json, ['brand', 'cardBrand'])),
        createdAt: asDate(pick(json, ['createdAt', 'date'])),
      );

  bool get isApproved {
    final s = status?.toLowerCase();
    return s == null || s == 'approved' || s == 'aprobado' || s == 'succeeded';
  }
}
