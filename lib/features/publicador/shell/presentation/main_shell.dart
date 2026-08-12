import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Barra inferior de 5 destinos del mockup, con el FAB naranja central de
/// "Publicar" elevado sobre la barra.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const List<({String route, IconData icon, String label})> _tabs = [
    (route: AppRoutes.home, icon: Icons.home_outlined, label: 'Inicio'),
    (route: AppRoutes.explore, icon: Icons.search, label: 'Explorar'),
    (route: AppRoutes.myOffers, icon: Icons.assignment_outlined, label: 'Mis ofertas'),
    (route: AppRoutes.profile, icon: Icons.person_outline, label: 'Perfil'),
  ];

  int _indexFor(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final current = _indexFor(location);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        heroTag: 'publish_fab',
        backgroundColor: AppColors.cta,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => context.push(AppRoutes.publish),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        height: 68,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              _NavItem(
                icon: _tabs[i].icon,
                label: _tabs[i].label,
                selected: current == i,
                onTap: () => context.go(_tabs[i].route),
              ),
              if (i == 1) const SizedBox(width: 56),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Container(
        width: 64,
        height: AppSpacing.touchTarget + 12,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
