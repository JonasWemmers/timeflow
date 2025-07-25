import 'package:flutter/material.dart';
import 'package:timeflow/auth/login/login_view.dart';
import 'package:timeflow/auth/register/register_view.dart';
import 'package:timeflow/dashboard/dashboard_view.dart';
import 'package:timeflow/routes/app_routes.dart';
import 'package:timeflow/splash_screen/splash_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterView());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardView());

      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('404 - Seite nicht gefunden')),
              ),
        );
    }
  }
}
