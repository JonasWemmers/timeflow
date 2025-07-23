import 'dart:async';
import 'dart:ui';

class SplashViewModel {
  final VoidCallback onFinished;

  SplashViewModel({required this.onFinished});

  void startSplash() {
    Timer(const Duration(seconds: 2), onFinished);
  }
}