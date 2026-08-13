import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/aplicante/about/presentation/about_screen.dart';
import '../../features/aplicante/applications/presentation/my_applications_screen.dart';
import '../../features/aplicante/auth/presentation/forgot_password_screen.dart';
import '../../features/aplicante/auth/presentation/login_screen.dart';
import '../../features/aplicante/auth/presentation/register_screen.dart';
import '../../features/aplicante/auth/state/session_controller.dart';
import '../../features/aplicante/experiences/presentation/experiences_screen.dart';
import '../../features/aplicante/likes/presentation/my_likes_screen.dart'; // <-- NUEVO
import '../../features/aplicante/offer_detail/presentation/offer_detail_screen.dart';
import '../../features/aplicante/profile/presentation/change_password_screen.dart';
import '../../features/aplicante/profile/presentation/complete_profile_screen.dart';
import '../../features/aplicante/profile/presentation/my_profile_screen.dart';
import '../../features/foro/presentation/forum_detail_screen.dart'; // <-- NUEVO
import '../../features/foro/presentation/forum_screen.dart'; // <-- NUEVO
import '../../features/publicador/contracts/presentation/my_contracts_screen.dart';
import '../../features/publicador/home/presentation/home_screen.dart';
import '../../features/publicador/my_offers/presentation/my_offers_screen.dart';
import '../../features/publicador/my_offers/presentation/offer_applicants_screen.dart';
import '../../features/publicador/news_videos_screen.dart';
import '../../features/publicador/offers/presentation/explore_offers_screen.dart';
import '../../features/publicador/offers/presentation/offers_map_screen.dart';
import '../../features/publicador/payments/presentation/my_payments_screen.dart';
import '../../features/publicador/publish_offer/presentation/publish_offer_flow.dart';
import '../../features/publicador/shell/presentation/main_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String completeProfile = '/complete-profile';

  static const String home = '/home';
  static const String explore = '/explore';
  static const String publish = '/publish';
  static const String myOffers = '/my-offers';
  static const String profile = '/profile';

  static const String newsVideos = '/news-videos';
  static const String map = '/map';
  static const String myApplications = '/my-applications';
  static const String experiences = '/experiences';
  static const String changePassword = '/change-password';
  static const String about = '/about';
  static const String myPayments = '/my-payments';
  static const String myContracts = '/my-contracts';
  static const String myLikes = '/my-likes'; // <-- NUEVO
  static const String forum = '/forum'; // <-- NUEVO

  static String offerDetail(String id) => '/offers/$id';
  static String offerApplicants(String id) => '/my-offers/$id/applicants';
  static String forumDetail(String id) => '/forum/$id'; // <-- NUEVO
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionControllerProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);

      // Mientras se restaura el token no se redirige a ningún lado.
      if (session.isLoading) return null;

      final user = session.valueOrNull;
      final loggedIn = user != null;
      final location = state.matchedLocation;

      const publicRoutes = <String>{
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      };
      final isPublic = publicRoutes.contains(location);

      // Guard 1: sin sesión → login.
      if (!loggedIn) return isPublic ? null : AppRoutes.login;

      // Guard 2: con sesión pero perfil incompleto → completar perfil.
      if (!user.profileCompleted && location != AppRoutes.completeProfile) {
        return AppRoutes.completeProfile;
      }

      // Ya autenticado y completo: fuera de las pantallas públicas.
      if (isPublic || (user.profileCompleted && location == AppRoutes.completeProfile)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (_, __) => const CompleteProfileScreen(),
      ),

      // Shell con la barra inferior
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: AppRoutes.explore,
            builder: (_, __) => const ExploreOffersScreen(),
          ),
          GoRoute(
            path: AppRoutes.myOffers,
            builder: (_, __) => const MyOffersScreen(),
          ),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const MyProfileScreen()),
        ],
      ),

      GoRoute(
        path: AppRoutes.publish,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PublishOfferFlow(),
      ),
      GoRoute(
        path: '/offers/:id',
        builder: (_, state) =>
            OfferDetailScreen(offerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/my-offers/:id/applicants',
        builder: (_, state) =>
            OfferApplicantsScreen(offerId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.map, builder: (_, __) => const OffersMapScreen()),
      GoRoute(
        path: AppRoutes.newsVideos,
        builder: (_, __) => const NewsVideosScreen(),
      ),
      GoRoute(
        path: AppRoutes.myApplications,
        builder: (_, __) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.experiences,
        builder: (_, __) => const ExperiencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(path: AppRoutes.about, builder: (_, __) => const AboutScreen()),
      GoRoute(
        path: AppRoutes.myPayments,
        builder: (_, __) => const MyPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.myContracts,
        builder: (_, __) => const MyContractsScreen(),
      ),

      GoRoute(
        path: AppRoutes.myLikes,
        builder: (_, __) => const MyLikesScreen(),
      ),
      GoRoute(
        path: AppRoutes.forum,
        builder: (_, __) => const ForumScreen(),
      ),
      GoRoute(
        path: '/forum/:id',
        builder: (_, state) =>
            ForumDetailScreen(topicId: state.pathParameters['id']!),
      ),
    ],
  );
});