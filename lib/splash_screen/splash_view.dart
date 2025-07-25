import 'package:flutter/material.dart';
import 'package:timeflow/constants/app_colors.dart';
import 'package:timeflow/auth/login/login_view.dart';
import 'splash_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final SplashViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SplashViewModel(onFinished: _navigateToLogin);
    _viewModel.startSplash();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Image.asset(
          'assets/img/timeflow_logo.png',
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}