import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../shared/widgets/async_view.dart';
import '../../auth/state/session_controller.dart';

/// Módulo 8 — muestra los datos de GET /me y es el hub de navegación
/// hacia el resto de pantallas personales.
class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: AsyncView(
        value: session,
        onRetry: () => ref.invalidate(sessionControllerProvider),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return RefreshIndicator(
            onRefresh: () => ref.read(sessionControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        user.initials,
                        style: AppTypography.headlineSm
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: AppTypography.headlineSm),
                          Text(user.email, style: AppTypography.bodyMd),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Cédula', value: user.cedula ?? '—'),
                        _InfoRow(label: 'Género', value: user.gender?.label ?? '—'),
                        _InfoRow(
                          label: 'Fecha de nacimiento',
                          value: DateFormats.short(user.birthDate),
                        ),
                        _InfoRow(
                          label: 'Matrícula de referido',
                          value: user.referralMatricula ?? '—',
                        ),
                        _InfoRow(
                          label: 'Miembro desde',
                          value: DateFormats.short(user.createdAt),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _NavTile(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Mis experiencias',
                  subtitle: 'Agrega tu historial y certificados',
                  onTap: () => context.push(AppRoutes.experiences),
                ),
                _NavTile(
                  icon: Icons.assignment_outlined,
                  title: 'Mis aplicaciones',
                  subtitle: 'Sigue el estado de tus postulaciones',
                  onTap: () => context.push(AppRoutes.myApplications),
                ),
                // --- NUEVO: OPCIÓN MIS ME GUSTA ---
                _NavTile(
                  icon: Icons.favorite_outline,
                  title: 'Mis me gusta',
                  subtitle: 'Ofertas guardadas en tus favoritos',
                  onTap: () => context.push(AppRoutes.myLikes),
                ),
                // --- NUEVO: OPCIÓN FORO ---
                _NavTile(
                  icon: Icons.forum_outlined,
                  title: 'Foro de la comunidad',
                  subtitle: 'Pregunta, debate y comparte con otros usuarios',
                  onTap: () => context.push(AppRoutes.forum),
                ),
                _NavTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Mis pagos',
                  subtitle: 'Historial de publicaciones pagadas',
                  onTap: () => context.push(AppRoutes.myPayments),
                ),
                _NavTile(
                  icon: Icons.handshake_outlined,
                  title: 'Mis contratos',
                  subtitle: 'Contratos como contratante o contratado',
                  onTap: () => context.push(AppRoutes.myContracts),
                ),
                _NavTile(
                  icon: Icons.newspaper_outlined,
                  title: 'Noticias y videos',
                  subtitle: 'Tendencias del mercado laboral',
                  onTap: () => context.push(AppRoutes.newsVideos),
                ),
                _NavTile(
                  icon: Icons.lock_outline,
                  title: 'Cambiar clave',
                  onTap: () => context.push(AppRoutes.changePassword),
                ),
                _NavTile(
                  icon: Icons.info_outline,
                  title: 'Acerca de',
                  onTap: () => context.push(AppRoutes.about),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(sessionControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMd)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.labelLg,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Icon(icon, color: AppColors.onSecondaryContainer, size: 20),
          ),
          title: Text(title, style: AppTypography.labelLg),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!, style: AppTypography.labelMd),
          trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
    );
  }
}