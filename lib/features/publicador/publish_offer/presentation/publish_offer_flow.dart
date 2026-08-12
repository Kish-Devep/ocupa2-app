import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/publish_offer_controller.dart';
import 'step1_details_screen.dart';
import 'step2_questions_screen.dart';
import 'step3_payment_screen.dart';

/// Contenedor del asistente de 3 pasos + pantalla de éxito.
class PublishOfferFlow extends ConsumerWidget {
  const PublishOfferFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(publishOfferControllerProvider);
    final controller = ref.read(publishOfferControllerProvider.notifier);

    if (state.created != null) {
      return _SuccessScreen(offerId: state.created!.id);
    }

    return PopScope(
      canPop: state.step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.goTo(state.step - 1);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => state.step == 0
                ? context.pop()
                : controller.goTo(state.step - 1),
          ),
          title: const Text('Publicar oferta'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Text('Paso ${state.step + 1} de 3',
                        style: AppTypography.labelMd),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (state.step + 1) / 3,
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: switch (state.step) {
                  0 => const Step1DetailsScreen(),
                  1 => const Step2QuestionsScreen(),
                  _ => const Step3PaymentScreen(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle,
                  size: 72, color: AppColors.statusWinnerFg),
              const SizedBox(height: AppSpacing.md),
              Text('¡Oferta publicada!',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLgMobile),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ya está visible para los aplicantes. Recibirás sus '
                'postulaciones en "Mis ofertas".',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Ver aplicantes',
                onPressed: () => context.go(AppRoutes.myOffers),
              ),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
