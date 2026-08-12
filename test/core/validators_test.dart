import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/utils/validators.dart';

void main() {
  group('email (format: email)', () {
    test('acepta un correo válido', () {
      expect(Validators.email('persona@correo.com'), isNull);
    });
    test('rechaza vacío y formatos inválidos', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('persona'), isNotNull);
      expect(Validators.email('persona@'), isNotNull);
      expect(Validators.email('persona@correo'), isNotNull);
    });
  });

  group('password (minLength: 6)', () {
    test('acepta 6 caracteres exactos', () {
      expect(Validators.password('123456'), isNull);
    });
    test('rechaza 5 caracteres', () {
      expect(Validators.password('12345'), isNotNull);
    });
  });

  group('cedula (11 dígitos, ignora guiones)', () {
    test('acepta 11 dígitos limpios', () {
      expect(Validators.cedula('40212345678'), isNull);
    });
    test('acepta el formato con guiones del mockup', () {
      expect(Validators.cedula('402-1234567-8'), isNull);
    });
    test('rechaza 10 y 12 dígitos', () {
      expect(Validators.cedula('4021234567'), isNotNull);
      expect(Validators.cedula('402123456789'), isNotNull);
    });
    test('digitsOnly elimina todo lo que no sea número', () {
      expect(Validators.digitsOnly('402-1234567-8'), '40212345678');
    });
  });

  group('birthDate (fecha no futura)', () {
    test('acepta una fecha pasada', () {
      expect(Validators.birthDate(DateTime(2004, 5, 17)), isNull);
    });
    test('acepta hoy', () {
      expect(Validators.birthDate(DateTime.now()), isNull);
    });
    test('rechaza mañana', () {
      expect(
        Validators.birthDate(DateTime.now().add(const Duration(days: 1))),
        isNotNull,
      );
    });
    test('rechaza null', () {
      expect(Validators.birthDate(null), isNotNull);
    });
  });

  group('name (minLength: 2)', () {
    test('rechaza una sola letra', () {
      expect(Validators.name('J'), isNotNull);
    });
    test('acepta dos letras', () {
      expect(Validators.name('Jo'), isNull);
    });
  });

  group('tarjeta de pago', () {
    test('acepta la tarjeta de prueba aprobada', () {
      expect(Validators.cardNumber('4242424242424242'), isNull);
    });
    test('acepta la tarjeta de prueba rechazada (es válida por Luhn)', () {
      expect(Validators.cardNumber('4000000000000002'), isNull);
    });
    test('rechaza un número que no pasa Luhn', () {
      expect(Validators.cardNumber('4242424242424243'), isNotNull);
    });
    test('valida el formato del vencimiento', () {
      expect(Validators.cardExpiry('13/30'), isNotNull);
      expect(Validators.cardExpiry('12/20'), isNotNull); // vencida
      expect(Validators.cardExpiry('12/40'), isNull);
    });
    test('valida el CVV', () {
      expect(Validators.cardCvv('12'), isNotNull);
      expect(Validators.cardCvv('123'), isNull);
      expect(Validators.cardCvv('1234'), isNull);
    });
  });

  group('positiveAmount', () {
    test('rechaza cero y negativos', () {
      expect(Validators.positiveAmount('0'), isNotNull);
      expect(Validators.positiveAmount('-5'), isNotNull);
    });
    test('acepta un monto positivo', () {
      expect(Validators.positiveAmount('1500'), isNull);
    });
  });
}
