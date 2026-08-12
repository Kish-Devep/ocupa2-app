import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/change_password_controller.dart';

/// Módulo 3 — PUT /me/password desde la sesión iniciada.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(changePasswordControllerProvider.notifier)
        .submit(_password.text);

    if (!mounted) return;
    if (ok) {
      showSuccessSnack(context, 'Clave actualizada correctamente.');
      context.pop();
    } else {
      final error = ref.read(changePasswordControllerProvider).error;
      if (error != null) showErrorSnack(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(changePasswordControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Cambiar clave'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Elige una clave nueva', style: AppTypography.headlineSm),
                const SizedBox(height: AppSpacing.base),
                Text('Mínimo 6 caracteres.', style: AppTypography.bodyMd),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Nueva clave',
                  controller: _password,
                  obscureText: true,
                  validator: Validators.password,
                  enabled: !loading,
                ),
                AppTextField(
                  label: 'Confirmar nueva clave',
                  controller: _confirm,
                  obscureText: true,
                  enabled: !loading,
                  validator: (v) => Validators.confirmPassword(v, _password.text),
                ),
                const SizedBox(height: AppSpacing.xs),
                PrimaryButton(
                  label: 'Guardar clave',
                  loading: loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
