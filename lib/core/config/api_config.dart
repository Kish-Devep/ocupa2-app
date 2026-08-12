/// Configuración del API real de producción. No hay modo offline ni mocks aquí:
/// los mocks viven exclusivamente en `test/`.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Costo fijo de publicar una oferta, según la documentación del API.
  static const double publishFeeAmount = 1.0;
  static const String publishFeeCurrency = 'USD';

  /// Tarjetas de prueba documentadas por el backend.
  static const String testCardApproved = '4242424242424242';
  static const String testCardDeclined = '4000000000000002';
}
