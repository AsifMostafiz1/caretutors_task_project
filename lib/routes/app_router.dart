import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:demo_project/presentation/auth/view/sign_in_screen.dart';
import 'package:demo_project/presentation/auth/view/sign_up_screen.dart';
import 'package:demo_project/presentation/dashboard/view/dashboard_screen.dart';
import 'package:demo_project/presentation/splash/view/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String dashboard = '/dashboard';
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.splash, builder: (BuildContext context, GoRouterState state) => const SplashScreen()),
      GoRoute(path: AppRoutes.signIn,builder: (BuildContext context, GoRouterState state) => const SignInScreen()),
      GoRoute(
        path: AppRoutes.signUp,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage<void>(
              key: state.pageKey,
              child: const SignUpScreen(),
              transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                final Animation<Offset> offsetAnimation = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                );

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
      ),
      GoRoute(path: AppRoutes.dashboard, builder: (BuildContext context, GoRouterState state) => const DashboardScreen()),
    ],
  );
}
