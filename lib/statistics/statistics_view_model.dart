import 'package:flutter/foundation.dart';
import 'package:timeflow/models/work_time.dart';
import 'package:timeflow/models/break.dart';
import 'package:timeflow/models/holiday.dart';
import 'package:timeflow/services/work_time_service.dart';
import 'package:timeflow/services/break_service.dart';
import 'package:timeflow/services/holiday_service.dart';

class StatisticsViewModel extends ChangeNotifier {
  final WorkTimeService _workTimeService = WorkTimeService();
  final BreakService _breakService = BreakService();
  final HolidayService _holidayService = HolidayService();

  List<WorkTime> _workTimes = [];
  List<Break> _breaks = [];
  List<Holiday> _holidays = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WorkTime> get workTimes => _workTimes;
  List<Break> get breaks => _breaks;
  List<Holiday> get holidays => _holidays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lädt alle Daten für die Statistik
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lade alle Daten parallel
      await Future.wait([_loadWorkTimes(), _loadBreaks(), _loadHolidays()]);
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Daten: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lädt alle Arbeitszeiten
  Future<void> _loadWorkTimes() async {
    try {
      _workTimes = await _workTimeService.getWorkTimes();
      // Sortiere nach Startzeit (neueste zuerst)
      _workTimes.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Arbeitszeiten: $e';
    }
  }

  /// Lädt alle Pausen
  Future<void> _loadBreaks() async {
    try {
      _breaks = await _breakService.getBreaks();
      // Sortiere nach Startzeit (neueste zuerst)
      _breaks.sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Pausen: $e';
    }
  }

  /// Lädt alle Urlaube
  Future<void> _loadHolidays() async {
    try {
      _holidays = await _holidayService.getHolidays();
      // Sortiere nach Startdatum (neueste zuerst)
      _holidays.sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Urlaube: $e';
    }
  }

  /// Löscht Fehlermeldungen
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Berechnet die Gesamtarbeitszeit für einen Zeitraum
  Duration getTotalWorkTime({DateTime? startDate, DateTime? endDate}) {
    Duration total = Duration.zero;

    for (final workTime in _workTimes) {
      if (workTime.endTime != null) {
        // Filtere nach Datum falls angegeben
        if (startDate != null && workTime.startTime.isBefore(startDate)) {
          continue;
        }
        if (endDate != null && workTime.startTime.isAfter(endDate)) {
          continue;
        }

        total += workTime.endTime!.difference(workTime.startTime);
      }
    }

    return total;
  }

  /// Berechnet die Gesamtpausenzeit für einen Zeitraum
  Duration getTotalBreakTime({DateTime? startDate, DateTime? endDate}) {
    Duration total = Duration.zero;

    for (final breakItem in _breaks) {
      if (breakItem.endTime != null) {
        // Filtere nach Datum falls angegeben
        if (startDate != null && breakItem.startTime.isBefore(startDate)) {
          continue;
        }
        if (endDate != null && breakItem.startTime.isAfter(endDate)) {
          continue;
        }

        total += breakItem.endTime!.difference(breakItem.startTime);
      }
    }

    return total;
  }

  /// Berechnet die Gesamturlaubstage für einen Zeitraum
  int getTotalHolidayDays({DateTime? startDate, DateTime? endDate}) {
    int total = 0;

    for (final holiday in _holidays) {
      // Filtere nach Datum falls angegeben
      if (startDate != null && holiday.endDate.isBefore(startDate)) {
        continue;
      }
      if (endDate != null && holiday.startDate.isAfter(endDate)) {
        continue;
      }

      total += holiday.endDate.difference(holiday.startDate).inDays + 1;
    }

    return total;
  }

  /// Berechnet die verfügbaren Urlaubstage
  int getAvailableHolidayDays() {
    const int totalHolidayDays = 30; // Gesamte verfügbare Urlaubstage
    int usedDays = 0;

    for (final holiday in _holidays) {
      usedDays += holiday.endDate.difference(holiday.startDate).inDays + 1;
    }

    return totalHolidayDays - usedDays;
  }

  /// Berechnet die genommenen Urlaubstage
  int getUsedHolidayDays() {
    int usedDays = 0;

    for (final holiday in _holidays) {
      usedDays += holiday.endDate.difference(holiday.startDate).inDays + 1;
    }

    return usedDays;
  }
}
