/// Validaciones de formulario. Funciones puras y estáticas: son la parte más
/// barata de testear y la que más errores atrapa (ver `validators_test.dart`).
///
/// Cada regla replica exactamente una restricción del schema OpenAPI.
class Validators {
  const Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// `format: email`
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El correo es obligatorio';
    if (!_emailRegExp.hasMatch(v)) return 'Correo no válido';
    return null;
  }

  /// `minLength: 6`
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'La clave es obligatoria';
    if (v.length < 6) return 'La clave debe tener al menos 6 caracteres';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirma la clave';
    if (value != original) return 'Las claves no coinciden';
    return null;
  }

  /// `minLength: 2` para firstName / lastName en PUT /me/profile.
  static String? name(String? value, {String label = 'Este campo'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$label es obligatorio';
    if (v.length < 2) return '$label debe tener al menos 2 caracteres';
    return null;
  }

  /// Cédula RD: 11 dígitos. El API ignora guiones y espacios, así que la app
  /// también los ignora antes de validar.
  static String? cedula(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return 'La cédula es obligatoria';
    if (digits.length != 11) return 'La cédula debe tener 11 dígitos';
    return null;
  }

  static String? referralMatricula(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'La matrícula de referido es obligatoria';
    if (v.length < 4) return 'Matrícula no válida';
    return null;
  }

  /// `description: Fecha no futura`
  static String? birthDate(DateTime? value) {
    if (value == null) return 'La fecha de nacimiento es obligatoria';
    final today = DateTime.now();
    final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);
    if (value.isAfter(endOfToday)) return 'La fecha no puede ser futura';
    if (value.isBefore(DateTime(1900))) return 'Fecha no válida';
    return null;
  }

  static String? required(String? value, {String label = 'Este campo'}) {
    if ((value?.trim() ?? '').isEmpty) return '$label es obligatorio';
    return null;
  }

  static String? minLength(String? value, int min, {String label = 'Este campo'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$label es obligatorio';
    if (v.length < min) return '$label debe tener al menos $min caracteres';
    return null;
  }

  static String? positiveAmount(String? value, {String label = 'El monto'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$label es obligatorio';
    final parsed = double.tryParse(v.replaceAll(',', ''));
    if (parsed == null) return '$label debe ser un número';
    if (parsed <= 0) return '$label debe ser mayor que cero';
    return null;
  }

  /// Luhn. El backend solo reconoce dos tarjetas de prueba, pero validar en el
  /// cliente evita un viaje inútil al servidor por un dígito mal tecleado.
  static String? cardNumber(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return 'El número de tarjeta es obligatorio';
    if (digits.length < 13 || digits.length > 19) {
      return 'Número de tarjeta no válido';
    }
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var digit = int.parse(digits[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    if (sum % 10 != 0) return 'Número de tarjeta no válido';
    return null;
  }

  /// Formato MM/AA y no vencida.
  static String? cardExpiry(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'El vencimiento es obligatorio';
    final match = RegExp(r'^(\d{2})\s*/?\s*(\d{2})$').firstMatch(v);
    if (match == null) return 'Usa el formato MM/AA';
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return 'Mes no válido';
    final expiry = DateTime(year, month + 1, 0);
    if (expiry.isBefore(DateTime.now())) return 'La tarjeta está vencida';
    return null;
  }

  static String? cardCvv(String? value) {
    final digits = digitsOnly(value ?? '');
    if (digits.isEmpty) return 'El CVV es obligatorio';
    if (digits.length < 3 || digits.length > 4) return 'CVV no válido';
    return null;
  }

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');
}
