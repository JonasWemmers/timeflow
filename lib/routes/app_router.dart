import 'package:flutter/material.dart';
import 'package:timeflow/auth/register/register_view.dart';
import 'package:timeflow/routes/app_routes.dart';
import 'package:timeflow/splash_screen/splash_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => SplashView(onFinished: () {  },));
        case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 - Seite nicht gefunden')),
          ),
        );
    }
  }
}
