import 'package:flutter/foundation.dart';
import 'package:timeflow/models/holiday.dart';
import 'package:timeflow/services/holiday_service.dart';

class HolidayViewModel extends ChangeNotifier {
  final HolidayService _holidayService = HolidayService();

  static const int totalHolidayDays = 30; // Gesamte verfügbare Urlaubstage

  List<Holiday> _holidays = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Holiday> get holidays => _holidays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Berechnet die verfügbaren Urlaubstage
  int get availableHolidayDays {
    int usedDays = 0;
    for (final holiday in _holidays) {
      usedDays += holiday.durationInDays;
    }
    return totalHolidayDays - usedDays;
  }

  /// Berechnet die genommenen Urlaubstage
  int get usedHolidayDays {
    int usedDays = 0;
    for (final holiday in _holidays) {
      usedDays += holiday.durationInDays;
    }
    return usedDays;
  }

  /// Lädt alle Urlaube
  Future<void> loadHolidays() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _holidays = await _holidayService.getHolidays();
      // Sortiere nach Startdatum (neueste zuerst)
      _holidays.sort((a, b) => b.startDate.compareTo(a.startDate));
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Urlaube: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Erstellt einen neuen Urlaub
  Future<bool> createHoliday({
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Berechne die Anzahl der Tage für den neuen Urlaub
      final newHolidayDays = endDate.difference(startDate).inDays + 1;

      // Prüfe ob genügend Urlaubstage verfügbar sind
      if (newHolidayDays > availableHolidayDays) {
        _errorMessage =
            'Nicht genügend Urlaubstage verfügbar. Verfügbar: $availableHolidayDays, Benötigt: $newHolidayDays';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Erstelle den Urlaub
      final newHoliday = await _holidayService.createHoliday(
        startDate: startDate,
        endDate: endDate,
        description: description,
      );

      // Füge den neuen Urlaub zur Liste hinzu
      _holidays.insert(0, newHoliday);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Fehler beim Erstellen des Urlaubs: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Löscht einen Urlaub
  Future<bool> deleteHoliday(String holidayId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _holidayService.deleteHoliday(holidayId);

      // Entferne den Urlaub aus der Liste
      _holidays.removeWhere((holiday) => holiday.id == holidayId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Fehler beim Löschen des Urlaubs: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Löscht Fehlermeldungen
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Prüft ob ein Datum bereits in einem Urlaub liegt
  bool isDateInHoliday(DateTime date) {
    for (final holiday in _holidays) {
      if (date.isAfter(holiday.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(holiday.endDate.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  /// Berechnet die Anzahl der Tage für einen Zeitraum
  int calculateDaysForRange(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays + 1;
  }
}
