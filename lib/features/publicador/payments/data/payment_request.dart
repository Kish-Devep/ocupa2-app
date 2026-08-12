import '../../../../core/config/api_config.dart';
import '../../../../core/network/json.dart';
import '../../../../core/utils/validators.dart';

/// Datos de la tarjeta para el cobro simulado de 1 USD.
///
/// Tarjetas de prueba documentadas:
///  - aprobada:  4242 4242 4242 4242
///  - rechazada: 4000 0000 0000 0002  → responde 402
class PaymentRequest {
  const PaymentRequest({
    required this.cardNumber,
    required this.cardName,
    required this.expiry,
    required this.cvv,
    this.amount = ApiConfig.publishFeeAmount,
    this.currency = ApiConfig.publishFeeCurrency,
  });

  final String cardNumber;
  final String cardName;

  /// Formato MM/AA tal como se teclea en el formulario.
  final String expiry;
  final String cvv;
  final double amount;
  final String currency;

  int get expMonth => int.parse(_expiryDigits.substring(0, 2));
  int get expYear => 2000 + int.parse(_expiryDigits.substring(2, 4));

  String get _expiryDigits => Validators.digitsOnly(expiry).padRight(4, '0');

  /// Body exacto según el schema OpenAPI de POST /payments:
  /// requeridos cardNumber, cvv, expMonth, expYear; opcional cardholder.
  /// El monto y la moneda NO se envían: el backend fija 1 USD del lado
  /// del servidor y no forman parte del schema documentado.
  JsonMap toJson() => <String, dynamic>{
        'cardNumber': Validators.digitsOnly(cardNumber),
        'cvv': Validators.digitsOnly(cvv),
        'expMonth': expMonth,
        'expYear': expYear,
        'cardholder': cardName.trim(),
      };
}
