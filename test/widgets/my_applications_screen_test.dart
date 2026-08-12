import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocupa2/core/network/api_exception.dart';
import 'package:ocupa2/features/aplicante/applications/presentation/my_applications_screen.dart';
import 'package:ocupa2/features/aplicante/applications/presentation/widgets/application_card.dart';
import 'package:ocupa2/shared/models/application.dart';
import 'package:ocupa2/shared/providers/applications_provider.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockApplicationsRepository applications;

  setUp(() => applications = MockApplicationsRepository());

  List<Override> overrides() => <Override>[
        applicationsRepositoryProvider.overrideWithValue(applications),
      ];

  Application withStatus(String id, ApplicationStatus status) =>
      Application.fromJson(<String, dynamic>{
        ...applicationJson,
        'id': id,
        'status': status.apiValue,
      });

  testWidgets('muestra un badge por cada estado documentado', (tester) async {
    when(() => applications.mine()).thenAnswer((_) async => <Application>[
          withStatus('a1', ApplicationStatus.applied),
          withStatus('a2', ApplicationStatus.discarded),
          withStatus('a3', ApplicationStatus.finalist),
          withStatus('a4', ApplicationStatus.winner),
        ]);

    await tester.pumpApp(const MyApplicationsScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.byType(ApplicationCard), findsNWidgets(4));
    expect(find.text('En revisión'), findsWidgets);
    expect(find.text('Descartado'), findsWidgets);
    expect(find.text('Finalista'), findsWidgets);
    expect(find.text('Ganador'), findsWidgets);
  });

  testWidgets('el filtro por estado reduce la lista', (tester) async {
    when(() => applications.mine()).thenAnswer((_) async => <Application>[
          withStatus('a1', ApplicationStatus.applied),
          withStatus('a2', ApplicationStatus.winner),
        ]);

    await tester.pumpApp(const MyApplicationsScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.byType(ApplicationCard), findsNWidgets(2));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Ganador'));
    await tester.pumpAndSettle();

    expect(find.byType(ApplicationCard), findsOneWidget);
  });

  testWidgets('estado vacío cuando no hay aplicaciones', (tester) async {
    when(() => applications.mine()).thenAnswer((_) async => <Application>[]);

    await tester.pumpApp(const MyApplicationsScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.text('Todavía no has aplicado'), findsOneWidget);
    expect(find.byType(ApplicationCard), findsNothing);
  });

  testWidgets('muestra el error del API con opción de reintentar',
      (tester) async {
    when(() => applications.mine()).thenThrow(const ApiException(
      kind: ApiErrorKind.network,
      message: 'Sin conexión a internet.',
    ));

    await tester.pumpApp(const MyApplicationsScreen(), overrides: overrides());
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión a internet.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
