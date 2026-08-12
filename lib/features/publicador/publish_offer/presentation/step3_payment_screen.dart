import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../payments/data/payment_request.dart';
import '../state/publish_offer_controller.dart';

/// Paso 3 — cobro simulado de 1 USD y publicación.
class Step3PaymentScreen extends ConsumerStatefulWidget {
  const Step3PaymentScreen({super.key});

  @override
  ConsumerState<Step3PaymentScreen> createState() => _Step3PaymentScreenState();
}

class _Step3PaymentScreenState extends ConsumerState<Step3PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref.read(publishOfferControllerProvider.notifier).payAndPublish(
          PaymentRequest(
            cardNumber: _number.text,
            cardName: _name.text,
            expiry: _expiry.text,
            cvv: _cvv.text,
          ),
        );

    if (!mounted || ok) return;
    final error = ref.read(publishOfferControllerProvider).error;
    if (error != null) showErrorSnack(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publishOfferControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pago de publicación', style: AppTypography.headlineLgMobile),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Revisa los detalles de tu oferta y completa el pago para publicarla.',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: AppSpacing.lg),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radius),
                        ),
                        child: const Icon(Icons.work_outline,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.jobType?.name ?? 'Oferta',
                                style: AppTypography.labelLg),
                            Text(
                              '${state.contractType.label} · '
                              '${DateFormats.money(state.amount, state.currency)}',
                              style: AppTypography.labelMd,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Costo de publicación', style: AppTypography.bodyLg),
                      Text(
                        DateFormats.money(
                          ApiConfig.publishFeeAmount,
                          ApiConfig.publishFeeCurrency,
                        ),
                        style: AppTypography.labelLg,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Impuestos aplicables', style: AppTypography.bodyMd),
                      Text('Incluidos', style: AppTypography.bodyMd),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total a pagar', style: AppTypography.headlineSm),
                      Text(
                        DateFormats.money(
                          ApiConfig.publishFeeAmount,
                          ApiConfig.publishFeeCurrency,
                        ),
                        style: AppTypography.headlineSm
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          if (state.paymentId != null)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.statusWinnerBg,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.statusWinnerFg, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'El pago ya fue aprobado. No se te cobrará de nuevo al '
                      'reintentar.',
                      style: AppTypography.labelMd
                          .copyWith(color: AppColors.statusWinnerFg),
                    ),
                  ),
                ],
              ),
            ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Detalles de pago', style: AppTypography.headlineSm),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Nombre en la tarjeta',
                      hint: 'Juan Pérez',
                      controller: _name,
                      enabled: !state.submitting,
                      validator: (v) =>
                          Validators.minLength(v, 3, label: 'El nombre'),
                    ),
                    AppTextField(
                      fieldKey: const Key('card_number'),
                      label: 'Número de tarjeta',
                      hint: '4242 4242 4242 4242',
                      controller: _number,
                      keyboardType: TextInputType.number,
                      enabled: !state.submitting,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(19),
                      ],
                      validator: Validators.cardNumber,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Vencimiento',
                            hint: 'MM/AA',
                            controller: _expiry,
                            keyboardType: TextInputType.number,
                            enabled: !state.submitting,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(5),
                            ],
                            validator: Validators.cardExpiry,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            label: 'CVV',
                            hint: '123',
                            controller: _cvv,
                            keyboardType: TextInputType.number,
                            enabled: !state.submitting,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: Validators.cardCvv,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    PrimaryButton(
                      key: const Key('publish_pay_button'),
                      label: 'Pagar y publicar (1.00 USD)',
                      icon: Icons.lock_outline,
                      cta: true,
                      loading: state.submitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
