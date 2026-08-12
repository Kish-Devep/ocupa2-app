import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/custom_field.dart';
import '../../../../shared/models/offer_input.dart';
import '../../../../shared/widgets/dynamic_form/dynamic_form.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/publish_offer_controller.dart';

/// Paso 2:
///  - Arriba: los campos personalizados del tipo de empleo (GET /job-types),
///    renderizados con EL MISMO `DynamicForm` que usa "aplicar a oferta".
///    Sus valores viajan en `customAnswers`.
///  - Abajo: el constructor de preguntas para los aplicantes (`questions`).
class Step2QuestionsScreen extends ConsumerStatefulWidget {
  const Step2QuestionsScreen({super.key});

  @override
  ConsumerState<Step2QuestionsScreen> createState() =>
      _Step2QuestionsScreenState();
}

class _Step2QuestionsScreenState extends ConsumerState<Step2QuestionsScreen> {
  late final DynamicFormController _dynamicForm;

  @override
  void initState() {
    super.initState();
    final state = ref.read(publishOfferControllerProvider);
    _dynamicForm = DynamicFormController(
      fields: state.jobTypeFields,
      initialValues: state.customAnswers,
    );
  }

  @override
  void dispose() {
    _dynamicForm.dispose();
    super.dispose();
  }

  void _next() {
    if (!_dynamicForm.validate()) return;
    final controller = ref.read(publishOfferControllerProvider.notifier);
    controller.setCustomAnswers(_dynamicForm.toAnswersMap());
    controller.goTo(2);
  }

  Future<void> _addQuestion() async {
    final question = await showModalBottomSheet<OfferQuestionInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => const _QuestionBuilderSheet(),
    );
    if (question != null) {
      ref.read(publishOfferControllerProvider.notifier).addQuestion(question);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publishOfferControllerProvider);
    final controller = ref.read(publishOfferControllerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Detalles del puesto', style: AppTypography.headlineLgMobile),
          const SizedBox(height: AppSpacing.base),
          Text(
            state.jobTypeFields.isEmpty
                ? 'Este tipo de empleo no tiene campos adicionales.'
                : 'Completa los campos propios de "${state.jobType?.name}".',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.lg),

          DynamicForm(controller: _dynamicForm),

          const Divider(height: AppSpacing.xl),

          Text('Preguntas para los aplicantes', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Opcional. Cada aplicante deberá responderlas al postularse.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.md),

          if (state.questions.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text('Todavía no agregaste preguntas.',
                  style: AppTypography.bodyMd),
            )
          else
            for (var i = 0; i < state.questions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Card(
                  child: ListTile(
                    title: Text(state.questions[i].label,
                        style: AppTypography.labelLg),
                    subtitle: Text(
                      '${state.questions[i].type.label}'
                      '${state.questions[i].required ? " · obligatoria" : ""}'
                      '${state.questions[i].options.isEmpty ? "" : " · ${state.questions[i].options.length} opciones"}',
                      style: AppTypography.labelMd,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => controller.removeQuestion(i),
                    ),
                  ),
                ),
              ),

          const SizedBox(height: AppSpacing.xs),
          OutlinedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Agregar pregunta'),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Continuar al pago',
            icon: Icons.arrow_forward,
            onPressed: _next,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

/// Constructor de una pregunta. Solo ofrece los 4 tipos que admite el enum
/// `OfferInput.questions[].type` (sin `number`).
class _QuestionBuilderSheet extends StatefulWidget {
  const _QuestionBuilderSheet();

  @override
  State<_QuestionBuilderSheet> createState() => _QuestionBuilderSheetState();
}

class _QuestionBuilderSheetState extends State<_QuestionBuilderSheet> {
  final _label = TextEditingController();
  final _options = TextEditingController();
  CustomFieldType _type = CustomFieldType.text;
  bool _required = false;

  @override
  void dispose() {
    _label.dispose();
    _options.dispose();
    super.dispose();
  }

  void _save() {
    final label = _label.text.trim();
    if (label.isEmpty) return;
    final options = _type == CustomFieldType.select
        ? _options.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : const <String>[];
    if (_type == CustomFieldType.select && options.isEmpty) return;

    Navigator.of(context).pop(
      OfferQuestionInput(
        label: label,
        type: _type,
        required: _required,
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.containerMargin,
        right: AppSpacing.containerMargin,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nueva pregunta', style: AppTypography.headlineSm),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _label,
            decoration: const InputDecoration(
              labelText: 'Pregunta',
              hintText: '¿Cuenta con herramientas propias?',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Tipo de respuesta', style: AppTypography.labelLg),
          const SizedBox(height: AppSpacing.base),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final type in CustomFieldType.allowedInOfferQuestions)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          if (_type == CustomFieldType.select) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _options,
              decoration: const InputDecoration(
                labelText: 'Opciones separadas por coma',
                hintText: 'Inmediata, En 2-3 días, La próxima semana',
              ),
            ),
          ],
          SwitchListTile(
            value: _required,
            onChanged: (v) => setState(() => _required = v),
            title: Text('Respuesta obligatoria', style: AppTypography.bodyLg),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.xs),
          PrimaryButton(label: 'Agregar pregunta', onPressed: _save),
        ],
      ),
    );
  }
}
