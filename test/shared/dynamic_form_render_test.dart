import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/shared/models/custom_field.dart';
import 'package:ocupa2/shared/widgets/dynamic_form/dynamic_form.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<DynamicFormController> pumpForm(
    WidgetTester tester,
    List<CustomField> fields,
  ) async {
    final controller = DynamicFormController(fields: fields);
    await tester.pumpApp(
      Scaffold(
        body: SingleChildScrollView(child: DynamicForm(controller: controller)),
      ),
    );
    return controller;
  }

  testWidgets('renderiza el widget correcto para cada uno de los 5 tipos',
      (tester) async {
    await pumpForm(tester, allFieldTypes);

    // text y number → TextFormField
    expect(find.byKey(const ValueKey('dynamic_field_nombre')), findsOneWidget);
    expect(find.byKey(const ValueKey('dynamic_field_anos')), findsOneWidget);
    // date → selector táctil
    expect(find.byKey(const ValueKey('dynamic_field_inicio')), findsOneWidget);
    // select → dropdown
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    // check → checkbox
    expect(find.byType(CheckboxListTile), findsOneWidget);

    // Y todas las etiquetas están visibles
    for (final field in allFieldTypes) {
      expect(find.textContaining(field.label), findsWidgets);
    }
  });

  testWidgets('un campo requerido muestra el asterisco', (tester) async {
    await pumpForm(tester, const <CustomField>[
      CustomField(
        key: 'obligatorio',
        label: 'Campo obligatorio',
        type: CustomFieldType.text,
        required: true,
      ),
    ]);

    final richText = tester.widget<Text>(find.byType(Text).first);
    expect(richText.textSpan!.toPlainText().contains('*'), isTrue);
  });

  testWidgets('no renderiza nada cuando no hay campos', (tester) async {
    await pumpForm(tester, const <CustomField>[]);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(CheckboxListTile), findsNothing);
  });

  testWidgets('validate() publica los errores en la UI', (tester) async {
    final controller = await pumpForm(tester, const <CustomField>[
      CustomField(
        key: 'req',
        label: 'Requerido',
        type: CustomFieldType.text,
        required: true,
      ),
    ]);

    expect(controller.validate(), isFalse);
    await tester.pump();
    expect(find.text('Requerido es obligatorio'), findsOneWidget);
  });

  testWidgets('escribir en un campo actualiza el controlador y limpia el error',
      (tester) async {
    final controller = await pumpForm(tester, const <CustomField>[
      CustomField(
        key: 'nombre',
        label: 'Nombre',
        type: CustomFieldType.text,
        required: true,
      ),
    ]);

    await tester.enterText(
      find.byKey(const ValueKey('dynamic_field_nombre')),
      'Juan Pérez',
    );
    await tester.pump();

    expect(controller.valueOf('nombre'), 'Juan Pérez');
    expect(controller.validate(), isTrue);
    expect(
      controller.toAnswersList(),
      <Map<String, dynamic>>[
        <String, dynamic>{'questionId': 'nombre', 'value': 'Juan Pérez'},
      ],
    );
    expect(controller.toAnswersMap(), <String, dynamic>{'nombre': 'Juan Pérez'});
  });

  testWidgets('marcar una casilla la refleja como bool en el controlador',
      (tester) async {
    final controller = await pumpForm(tester, const <CustomField>[
      CustomField(key: 'acepto', label: 'Acepto', type: CustomFieldType.check),
    ]);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(controller.valueOf('acepto'), isTrue);
    expect(controller.toAnswersMap()['acepto'], isTrue);
  });
}
