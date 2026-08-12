import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/features/aplicante/auth/presentation/login_screen.dart';
import 'package:ocupa2/features/aplicante/auth/state/session_controller.dart';
import 'package:ocupa2/features/aplicante/profile/data/profile_repository.dart';
import 'package:ocupa2/core/network/network_providers.dart';
import 'package:ocupa2/shared/models/auth_session.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthRepository auth;
  late MockProfileRepository profile;

  setUp(() {
    auth = MockAuthRepository();
    profile = MockProfileRepository();
  });

  List<Override> overrides() => <Override>[
        tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profile),
      ];

  testWidgets('muestra los campos de correo y clave, sin rastro de OTP',
      (tester) async {
    await tester.pumpApp(const LoginScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Clave'), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
    expect(find.textContaining('código'), findsNothing);
    expect(find.textContaining('OTP'), findsNothing);
  });

  testWidgets('valida el formulario antes de llamar al API', (tester) async {
    await tester.pumpApp(const LoginScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
    expect(find.text('La clave es obligatoria'), findsOneWidget);
    verifyNever(() => auth.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets('rechaza un correo con formato inválido', (tester) async {
    await tester.pumpApp(const LoginScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login_email')), 'no-es-correo');
    await tester.enterText(find.byKey(const Key('login_password')), '123456');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Correo no válido'), findsOneWidget);
    verifyNever(() => auth.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  testWidgets('con datos válidos llama a POST /auth/login', (tester) async {
    when(() => auth.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => AuthSession.fromJson(sessionJson));

    await tester.pumpApp(const LoginScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login_email')), 'persona@correo.com');
    await tester.enterText(find.byKey(const Key('login_password')), 'secreto123');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    verify(() => auth.login(
          email: 'persona@correo.com',
          password: 'secreto123',
        )).called(1);
  });

  testWidgets('un 401 muestra "Correo o clave incorrectos"', (tester) async {
    when(() => auth.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(const ApiException(
      kind: ApiErrorKind.unauthorized,
      statusCode: 401,
      message: 'Unauthorized',
    ));

    await tester.pumpApp(const LoginScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login_email')), 'persona@correo.com');
    await tester.enterText(find.byKey(const Key('login_password')), 'incorrecta');
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Correo o clave incorrectos.'), findsOneWidget);
  });
}
