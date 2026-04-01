import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/routes/presentation/route_list_screen.dart';
import '../../features/routes/presentation/route_detail_screen.dart';
import '../../features/routes/presentation/route_create_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/widgets/bottom_nav_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/map',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/map';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavScaffold(child: child),
        routes: [
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/routes',
            builder: (context, state) => const RouteListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const RouteCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    RouteDetailScreen(routeId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
