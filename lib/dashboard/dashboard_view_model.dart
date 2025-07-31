import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/work_time.dart';
import '../models/break.dart';
import '../models/holiday.dart';
import '../services/work_time_service.dart';
import '../services/break_service.dart';
import '../services/holiday_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final WorkTimeService _workTimeService = WorkTimeService();
  final BreakService _breakService = BreakService();
  final HolidayService _holidayService = HolidayService();

  WorkTime? _activeWorkTime;
  Break? _activeBreak;
  WorkTime? _lastCompletedWorkTime; // Added for today's work time statistics
  List<Break> _breaks = []; // Speichert alle Pausen für die aktive Arbeitszeit
  List<Holiday> _holidays = [];
  bool _isLoading = false;
  String? _errorMessage;

  WorkTime? get activeWorkTime => _activeWorkTime;
  Break? get activeBreak => _activeBreak;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isWorking => _activeWorkTime != null && _activeWorkTime!.isActive;
  bool get isOnBreak => _activeBreak != null && _activeBreak!.isActive;

  /// Berechnet die verfügbaren Urlaubstage
  int get availableHolidayDays {
    const int totalHolidayDays = 30; // Gesamte verfügbare Urlaubstage
    int usedDays = 0;

    for (final holiday in _holidays) {
      usedDays += holiday.endDate.difference(holiday.startDate).inDays + 1;
    }

    return totalHolidayDays - usedDays;
  }

  /// Berechnet die genommenen Urlaubstage
  int get usedHolidayDays {
    int usedDays = 0;

    for (final holiday in _holidays) {
      usedDays += holiday.endDate.difference(holiday.startDate).inDays + 1;
    }

    return usedDays;
  }

  /// Lädt den aktuellen Status
  Future<void> loadCurrentStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeWorkTime = await _workTimeService.getActiveWorkTime();
      _activeBreak = await _breakService.getActiveBreak();

      // Lade alle Pausen für die aktive Arbeitszeit
      if (_activeWorkTime != null) {
        // Lade alle Pausen und filtere nach der aktiven Arbeitszeit
        final allBreaks = await _breakService.getBreaks();
        _breaks =
            allBreaks.where((breakItem) {
              // Filtere Pausen, die zur aktuellen Arbeitszeit gehören
              // Eine Pause gehört zur aktuellen Arbeitszeit, wenn:
              // 1. Sie die gleiche work_time_id hat
              // 2. Sie beendet ist (endTime != null)

              final hasSameWorkTimeId =
                  breakItem.workTimeId == _activeWorkTime!.id;
              final isCompleted = breakItem.endTime != null;

              return hasSameWorkTimeId && isCompleted;
            }).toList();
      } else {
        _breaks = [];
      }

      // Wenn keine aktive Arbeitszeit vorhanden ist, lade die letzte beendete Zeit für heute
      if (_activeWorkTime == null) {
        final todayWorkTimes = await _workTimeService.getWorkTimes();
        if (todayWorkTimes.isNotEmpty) {
          // Nehme die letzte Arbeitszeit (die neueste)
          final lastWorkTime = todayWorkTimes.first;
          if (lastWorkTime.endTime != null) {
            // Speichere die letzte beendete Zeit für die Statistik
            _lastCompletedWorkTime = lastWorkTime;
          }
        }
      }

      // Lade Urlaubsdaten
      _holidays = await _holidayService.getHolidays();
    } catch (e) {
      _errorMessage = 'Fehler beim Laden des Status: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Startet eine neue Arbeitszeit
  Future<void> startWork() async {
    if (isWorking) {
      _errorMessage = 'Arbeitszeit läuft bereits';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeWorkTime = await _workTimeService.startWorkTime();
      await loadCurrentStatus(); // Status neu laden
    } catch (e) {
      _errorMessage = 'Fehler beim Starten der Arbeitszeit: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Beendet die Arbeitszeit
  Future<void> endWork() async {
    if (!isWorking || _activeWorkTime?.id == null) {
      _errorMessage = 'Keine aktive Arbeitszeit gefunden';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Beende die Arbeitszeit
      final endedWorkTime = await _workTimeService.endWorkTime(
        _activeWorkTime!.id!,
      );

      // Speichere die beendete Zeit für die Statistik
      _lastCompletedWorkTime = endedWorkTime;

      // Setze aktive Zeit auf null, damit Timer stoppt
      _activeWorkTime = null;

      await loadCurrentStatus(); // Status neu laden
    } catch (e) {
      _errorMessage = 'Fehler beim Beenden der Arbeitszeit: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Startet eine Pause
  Future<void> startBreak() async {
    if (isOnBreak) {
      _errorMessage = 'Pause läuft bereits';
      notifyListeners();
      return;
    }

    if (!isWorking) {
      _errorMessage = 'Arbeitszeit muss aktiv sein, um eine Pause zu starten';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeBreak = await _breakService.startBreak();
      await loadCurrentStatus(); // Status neu laden
      notifyListeners(); // UI aktualisieren
    } catch (e) {
      _errorMessage = 'Fehler beim Starten der Pause: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Beendet eine Pause
  Future<void> endBreak() async {
    if (!isOnBreak || _activeBreak?.id == null) {
      _errorMessage = 'Keine aktive Pause gefunden';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeBreak = await _breakService.endBreak(_activeBreak!.id!);
      await loadCurrentStatus(); // Status neu laden
      notifyListeners(); // UI aktualisieren
    } catch (e) {
      _errorMessage = 'Fehler beim Beenden der Pause: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Berechnet die Netto-Arbeitszeit (ohne Pausen)
  Duration _calculateNetDuration() {
    if (_activeWorkTime == null) {
      return Duration.zero;
    }

    final now = DateTime.now().toUtc();
    final end = _activeWorkTime!.endTime ?? now;
    Duration total = end.difference(_activeWorkTime!.startTime);

    // Subtrahiere alle beendeten Pausen
    for (final b in _breaks) {
      if (b.endTime != null) {
        final breakDuration = b.endTime!.difference(b.startTime);
        total -= breakDuration;
      }
    }

    // Wenn eine aktive Pause läuft, "friere" die Arbeitszeit ein
    if (_activeBreak != null) {
      final activeBreakStart = _activeBreak!.startTime;
      final activeBreakDuration = now.difference(activeBreakStart);
      total -= activeBreakDuration;
    }

    final result = total.isNegative ? Duration.zero : total;
    return result;
  }

  /// Gibt die aktuelle Arbeitszeit als String zurück
  String getWorkTimeDisplay() {
    if (_activeWorkTime == null) {
      return '0:00';
    }

    // Wenn die Arbeitszeit beendet wurde, zeige die Gesamtdauer
    if (_activeWorkTime!.endTime != null) {
      final duration = _calculateNetDuration();
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    // Wenn die Arbeitszeit noch läuft, berechne die aktuelle Netto-Dauer
    final duration = _calculateNetDuration();
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatiert die Arbeitszeit für die Statistik (Heute)
  String getTodayWorkTimeDisplay() {
    // Wenn eine aktive Arbeitszeit vorhanden ist, verwende diese
    if (_activeWorkTime != null) {
      final duration = _calculateNetDuration();
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    // Wenn keine aktive Zeit vorhanden ist, verwende die letzte beendete Zeit
    if (_lastCompletedWorkTime != null) {
      final duration = _lastCompletedWorkTime!.endTime!.difference(
        _lastCompletedWorkTime!.startTime,
      );

      if (duration.isNegative) {
        return '0:00';
      }

      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '0:00';
  }

  /// Formatiert die Pausenzeit für die Anzeige
  String getBreakTimeDisplay() {
    if (_activeBreak == null) return '0:00';

    final startTime = _activeBreak!.startTime;
    final now = DateTime.now().toUtc();

    // Stelle sicher, dass die Startzeit nicht in der Zukunft liegt
    if (startTime.isAfter(now)) {
      return '0:00';
    }

    final duration = now.difference(startTime);

    // Stelle sicher, dass die Dauer nicht negativ ist
    if (duration.isNegative) {
      return '0:00';
    }

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Löscht Fehlermeldungen
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
