import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/app_shell.dart';
import '../landing/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/terms_screen.dart';
import '../screens/browse_screen.dart';
import '../screens/tutor_detail_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/tutor_dashboard_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/chats_screen.dart';
import '../screens/chat_screen.dart';

import '../core/theme.dart';
import '../core/constants.dart';

GoRouter buildRouter(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (ctx, state) {
      final loggedIn = authProvider.isLoggedIn;
      final isTutor  = authProvider.isTutor;
      final loc      = state.matchedLocation;

      const publicRoutes = ['/', '/login', '/register', '/privacy', '/terms'];
      final isPublic = publicRoutes.contains(loc);

      if (!loggedIn && !isPublic) return '/login';
      if (loggedIn && (loc == '/login' || loc == '/register' || loc == '/')) {
        return isTutor ? '/dashboard' : '/browse';
      }

      // Role guards
      if (isTutor && loc == '/my-requests') return '/dashboard';
      if (!isTutor && (loc.startsWith('/dashboard'))) return '/browse';

      return null;
    },
    errorBuilder: (ctx, state) => const _Custom404Screen(),
    routes: [
      // Public routes
      GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
      GoRoute(
        path: '/login',
        builder: (_, __) => Title(
          title: 'Log in | StudyCircle',
          color: AppColors.primary,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => Title(
          title: 'Create Account | StudyCircle',
          color: AppColors.primary,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (_, __) => const TermsOfServiceScreen(),
      ),


      // Shell wraps all authenticated screens
      ShellRoute(
        builder: (ctx, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/browse',
            builder: (_, __) => Title(
              title: 'Browse Tutors | StudyCircle',
              color: AppColors.primary,
              child: const BrowseScreen(),
            ),
          ),
          GoRoute(
            path: '/tutors/:id',
            builder: (_, state) => Title(
              title: 'Tutor Profile | StudyCircle',
              color: AppColors.primary,
              child: TutorDetailScreen(
                tutorId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ),
          GoRoute(
            path: '/my-requests',
            builder: (_, __) => Title(
              title: 'My Requests | StudyCircle',
              color: AppColors.primary,
              child: const MyRequestsScreen(),
            ),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => Title(
              title: 'Tutor Dashboard | StudyCircle',
              color: AppColors.primary,
              child: const TutorDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/dashboard/profile',
            builder: (_, __) => Title(
              title: 'Edit Profile | StudyCircle',
              color: AppColors.primary,
              child: const EditProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/chats',
            builder: (_, __) => Title(
              title: 'Chats | StudyCircle',
              color: AppColors.primary,
              child: const ChatsScreen(),
            ),
          ),
          GoRoute(
            path: '/chats/:requestId',
            builder: (_, state) => Title(
              title: 'Chat Room | StudyCircle',
              color: AppColors.primary,
              child: ChatScreen(
                requestId: int.parse(state.pathParameters['requestId']!),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Custom 404 Screen
// ---------------------------------------------------------------------------
class _Custom404Screen extends StatelessWidget {
  const _Custom404Screen();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    final destination = !auth.isLoggedIn
        ? '/'
        : (auth.isTutor ? '/dashboard' : '/browse');

    final buttonLabel = !auth.isLoggedIn
        ? 'Return to Home'
        : (auth.isTutor ? 'Go to Dashboard' : 'Browse Tutors');

    return Title(
      title: 'Page Not Found | Peer Tutoring Board',
      color: AppColors.primary,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(AppLayout.space32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.search_off_outlined,
                      size: 32,
                      color: AppColors.declined,
                    ),
                  ),
                  const SizedBox(height: AppLayout.space20),
                  Text('404 — Page Not Found', style: tt.displaySmall),
                  const SizedBox(height: AppLayout.space8),
                  Text(
                    'The page or resource you requested could not be found or may have moved.',
                    style: tt.bodyMedium?.copyWith(color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppLayout.space24),
                  FilledButton.icon(
                    onPressed: () => context.go(destination),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text(buttonLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
