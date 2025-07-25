import 'dart:async';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  final Stopwatch _workStopwatch = Stopwatch();
  final Stopwatch _pauseStopwatch = Stopwatch();
  Timer? _timer;

  Duration _elapsedWork = Duration.zero;
  Duration _elapsedPause = Duration.zero;

  bool _isRunning = false;
  bool _isPaused = false;

  // ✅ Urlaub-Variablen
  final int _totalVacationDays = 30; // z.B. 30 Tage pro Jahr
  int _usedVacationDays = 12;  // Beispiel: schon 12 Tage genommen

  // Getter
  Duration get elapsedWork => _elapsedWork;
  Duration get elapsedPause => _elapsedPause;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  // Dummy Statistik (später aus DB / SharedPrefs)
  Duration get weekTotal => const Duration(hours: 12, minutes: 45);
  Duration get monthTotal => const Duration(hours: 45, minutes: 30);

  // ✅ Urlaub Getter
  int get remainingVacationDays => _totalVacationDays - _usedVacationDays;
  int get totalVacationDays => _totalVacationDays;
  int get usedVacationDays => _usedVacationDays;

  // ✅ Urlaub beantragen (dummy)
  void applyForVacation(int days) {
    if (_usedVacationDays + days <= _totalVacationDays) {
      _usedVacationDays += days;
      notifyListeners();
    } else {
      // Optional: Fehlerbehandlung (z.B. SnackBar später)
      debugPrint("Nicht genug Urlaubstage verfügbar!");
    }
  }

  // ✅ Timer-Methoden
  void start() {
    _isRunning = true;
    _isPaused = false;
    _workStopwatch.start();
    _startTimer();
    notifyListeners();
  }

  void stop() {
    _isPaused = true;
    _workStopwatch.stop();
    _pauseStopwatch.start();
    notifyListeners();
  }

  void resume() {
    _isPaused = false;
    _pauseStopwatch.stop();
    _pauseStopwatch.reset();
    _workStopwatch.start();
    _startTimer();
    notifyListeners();
  }

  void end() {
    _isRunning = false;
    _isPaused = false;
    _workStopwatch.stop();
    _pauseStopwatch.stop();
    _workStopwatch.reset();
    _pauseStopwatch.reset();
    _elapsedWork = Duration.zero;
    _elapsedPause = Duration.zero;
    _timer?.cancel();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_workStopwatch.isRunning) {
        _elapsedWork = _workStopwatch.elapsed;
      }
      if (_pauseStopwatch.isRunning) {
        _elapsedPause = _pauseStopwatch.elapsed;
      }
      notifyListeners();
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
