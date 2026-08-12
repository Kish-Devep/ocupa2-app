import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/features/aplicante/offer_detail/presentation/apply_form_section.dart';
import 'package:ocupa2/shared/models/application.dart';
import 'package:ocupa2/shared/models/offer.dart';
import 'package:ocupa2/shared/providers/applications_provider.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockApplicationsRepository applications;

  setUp(() => applications = MockApplicationsRepository());

  Future<void> pumpForm(WidgetTester tester, {Offer? offer}) async {
    await tester.pumpApp(
      Scaffold(
        body: SingleChildScrollView(
          child: ApplyFormSection(offer: offer ?? testOffer),
        ),
      ),
      overrides: <Override>[
        applicationsRepositoryProvider.overrideWithValue(applications),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renderiza las preguntas dinámicas de la oferta', (tester) async {
    await pumpForm(tester);

    // La oferta de prueba trae una pregunta de tipo check.
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.textContaining('licencia categoría 03'), findsOneWidget);
    expect(find.byKey(const Key('apply_comment')), findsOneWidget);
  });

  testWidgets('exige el comentario obligatorio', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.byKey(const Key('apply_submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('El comentario'), findsWidgets);
    verifyNever(() => applications.apply(
          offerId: any(named: 'offerId'),
          comment: any(named: 'comment'),
          answers: any(named: 'answers'),
        ));
  });

  testWidgets('exige responder las preguntas obligatorias', (tester) async {
    await pumpForm(tester);

    await tester.enterText(
      find.byKey(const Key('apply_comment')),
      'Tengo cinco años de experiencia como chofer.',
    );
    await tester.tap(find.byKey(const Key('apply_submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Debes marcar'), findsOneWidget);
    verifyNever(() => applications.apply(
          offerId: any(named: 'offerId'),
          comment: any(named: 'comment'),
          answers: any(named: 'answers'),
        ));
  });

  testWidgets('envía comentario y respuestas al completar todo', (tester) async {
    when(() => applications.apply(
          offerId: any(named: 'offerId'),
          comment: any(named: 'comment'),
          answers: any(named: 'answers'),
        )).thenAnswer((_) async => testApplication);

    await pumpForm(tester);

    await tester.enterText(
      find.byKey(const Key('apply_comment')),
      'Tengo cinco años de experiencia como chofer.',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('apply_submit')));
    await tester.pumpAndSettle();

    final captured = verify(() => applications.apply(
          offerId: 'o1',
          comment: captureAny(named: 'comment'),
          answers: captureAny(named: 'answers'),
        )).captured;

    expect(captured[0], 'Tengo cinco años de experiencia como chofer.');
    expect(captured[1], <Map<String, dynamic>>[
      <String, dynamic>{'questionId': 'q1', 'value': true},
    ]);
  });

  testWidgets('un 409 muestra "Ya aplicaste a esta oferta"', (tester) async {
    when(() => applications.apply(
          offerId: any(named: 'offerId'),
          comment: any(named: 'comment'),
          answers: any(named: 'answers'),
        )).thenThrow(const ApiException(
      kind: ApiErrorKind.conflict,
      statusCode: 409,
      message: 'Conflict',
    ));

    await pumpForm(tester);

    await tester.enterText(
      find.byKey(const Key('apply_comment')),
      'Tengo cinco años de experiencia como chofer.',
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('apply_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Ya aplicaste a esta oferta.'), findsOneWidget);
  });

  testWidgets('si ya apliqué, muestra el aviso y oculta el formulario',
      (tester) async {
    final applied = Offer.fromJson(<String, dynamic>{
      ...offerJson,
      'myApplicationStatus': ApplicationStatus.applied.apiValue,
    });

    await pumpForm(tester, offer: applied);

    expect(find.textContaining('Ya aplicaste a esta oferta'), findsOneWidget);
    expect(find.byKey(const Key('apply_submit')), findsNothing);
  });
}
