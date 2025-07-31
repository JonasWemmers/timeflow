import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/holiday.dart';

class HolidayService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Erstellt einen neuen Urlaub
  Future<Holiday> createHoliday({
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Benutzer nicht authentifiziert');
    }

    final data = {
      'user_id': user.id,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'description': description,
    };

    final response =
        await _supabase.from('holidays').insert(data).select().single();

    return Holiday.fromJson(response);
  }

  /// Holt alle Urlaube für einen bestimmten Zeitraum
  Future<List<Holiday>> getHolidays({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _supabase
        .from('holidays')
        .select()
        .order('start_date', ascending: false);

    List<Holiday> holidays =
        response.map((json) => Holiday.fromJson(json)).toList();

    // Filter client-side
    if (startDate != null) {
      holidays =
          holidays
              .where(
                (h) => h.startDate.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ),
              )
              .toList();
    }
    if (endDate != null) {
      holidays =
          holidays
              .where(
                (h) => h.endDate.isBefore(endDate.add(const Duration(days: 1))),
              )
              .toList();
    }

    return holidays;
  }

  /// Holt alle Urlaube für das aktuelle Jahr
  Future<List<Holiday>> getHolidaysForYear(int year) async {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31);

    return await getHolidays(startDate: startOfYear, endDate: endOfYear);
  }

  /// Aktualisiert einen Urlaub
  Future<Holiday> updateHoliday(Holiday holiday) async {
    final response =
        await _supabase
            .from('holidays')
            .update(holiday.toJson())
            .eq('id', holiday.id!)
            .select()
            .single();

    return Holiday.fromJson(response);
  }

  /// Löscht einen Urlaub
  Future<void> deleteHoliday(String holidayId) async {
    await _supabase.from('holidays').delete().eq('id', holidayId);
  }

  /// Berechnet die Gesamturlaubstage für einen Zeitraum
  Future<int> getTotalHolidayDays({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final holidays = await getHolidays(startDate: startDate, endDate: endDate);

    int totalDays = 0;
    for (final holiday in holidays) {
      totalDays += holiday.durationInDays;
    }

    return totalDays;
  }

  /// Prüft ob ein Datum in einem Urlaub liegt
  Future<bool> isDateInHoliday(DateTime date) async {
    final holidays = await getHolidays();

    for (final holiday in holidays) {
      if (date.isAfter(holiday.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(holiday.endDate.add(const Duration(days: 1)))) {
        return true;
      }
    }

    return false;
  }
}
