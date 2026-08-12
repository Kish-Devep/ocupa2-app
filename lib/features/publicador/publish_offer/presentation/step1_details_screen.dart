import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/offer.dart';
import '../../../../shared/providers/job_types_provider.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/location_picker_field.dart';
import '../../../../shared/widgets/photo_picker_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/publish_offer_controller.dart';

/// Paso 1: detalles de la oferta. Tipo de empleo desde GET /job-types,
/// foto OBLIGATORIA (el schema solo admite una URL).
class Step1DetailsScreen extends ConsumerStatefulWidget {
  const Step1DetailsScreen({super.key});

  @override
  ConsumerState<Step1DetailsScreen> createState() => _Step1DetailsScreenState();
}

class _Step1DetailsScreenState extends ConsumerState<Step1DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _description;
  late final TextEditingController _address;
  late final TextEditingController _amount;
  bool _photoTouched = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(publishOfferControllerProvider);
    _description = TextEditingController(text: state.description);
    _address = TextEditingController(text: state.address);
    _amount = TextEditingController(
      text: state.amount == null ? '' : state.amount!.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _description.dispose();
    _address.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _next() {
    final controller = ref.read(publishOfferControllerProvider.notifier);
    controller.setDescription(_description.text);
    controller.setAddress(_address.text);
    controller.setAmount(
      double.tryParse(_amount.text.replaceAll(',', '').trim()),
    );

    setState(() => _photoTouched = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    final state = ref.read(publishOfferControllerProvider);

    if (state.jobType == null) {
      showErrorSnack(context, 'Selecciona el tipo de empleo.');
      return;
    }
    if (state.photo == null) {
      showErrorSnack(context, 'La foto de la oferta es obligatoria.');
      return;
    }
    if (!formValid) return;

    controller.goTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publishOfferControllerProvider);
    final controller = ref.read(publishOfferControllerProvider.notifier);
    final jobTypes = ref.watch(jobTypesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Detalles de la oferta', style: AppTypography.headlineLgMobile),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Describe lo que necesitas con la mayor claridad posible.',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Tipo de empleo *', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.base),
            jobTypes.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text(
                'No pudimos cargar los tipos de empleo.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.error),
              ),
              data: (types) => DropdownButtonFormField<String>(
                key: const Key('publish_job_type'),
                value: state.jobType?.key,
                isExpanded: true,
                decoration:
                    const InputDecoration(hintText: 'Selecciona una categoría…'),
                items: types
                    .map((t) =>
                        DropdownMenuItem(value: t.key, child: Text(t.name)))
                    .toList(),
                onChanged: (key) {
                  final selected = types.firstWhere(
                    (t) => t.key == key,
                    orElse: () => types.first,
                  );
                  controller.setJobType(selected);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Tipo de contrato *', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.base),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final type in ContractType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: state.contractType == type,
                    onSelected: (_) => controller.setContractType(type),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              fieldKey: const Key('publish_description'),
              label: 'Descripción detallada *',
              hint: 'Tareas, requisitos y cualquier información relevante…',
              controller: _description,
              maxLines: 5,
              validator: (v) =>
                  Validators.minLength(v, 10, label: 'La descripción'),
            ),
            AppTextField(
              fieldKey: const Key('publish_address'),
              label: 'Dirección *',
              hint: 'Ej. Ensanche Naco, Distrito Nacional',
              controller: _address,
              validator: (v) => Validators.minLength(v, 3, label: 'La dirección'),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    fieldKey: const Key('publish_amount'),
                    label: 'Pago ofrecido *',
                    hint: '1500',
                    controller: _amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.positiveAmount,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 26),
                    child: DropdownButtonFormField<String>(
                      value: state.currency,
                      items: const [
                        DropdownMenuItem(value: 'DOP', child: Text('DOP')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                      ],
                      onChanged: (v) => controller.setCurrency(v ?? 'DOP'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            LocationPickerField(
              value: state.location,
              onChanged: controller.setLocation,
            ),

            PhotoPickerField(
              label: 'Foto de la oferta',
              required: true,
              helperText: 'Toca para tomar una foto o elegir de la galería.',
              photo: state.photo,
              onPicked: controller.setPhoto,
              errorText: _photoTouched && state.photo == null
                  ? 'La foto es obligatoria'
                  : null,
            ),

            Text('Fecha límite para aplicar', style: AppTypography.labelLg),
            const SizedBox(height: AppSpacing.base),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.deadline ?? now.add(const Duration(days: 7)),
                  firstDate: now,
                  lastDate: DateTime(now.year + 2),
                  locale: const Locale('es'),
                );
                if (picked != null) controller.setDeadline(picked);
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.deadline == null
                            ? 'Opcional'
                            : DateFormats.long(state.deadline),
                        style: state.deadline == null
                            ? const TextStyle(color: AppColors.outline)
                            : AppTypography.bodyLg,
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              key: const Key('publish_step1_next'),
              label: 'Siguiente',
              icon: Icons.arrow_forward,
              onPressed: _next,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
