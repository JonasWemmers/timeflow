import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/break.dart';
import 'work_time_service.dart';

class BreakService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final WorkTimeService _workTimeService = WorkTimeService();

  /// Startet eine neue Pause
  Future<Break> startBreak() async {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Benutzer nicht authentifiziert');
    }

    // Hole die aktive Arbeitszeit über den WorkTimeService
    final activeWorkTime = await _workTimeService.getActiveWorkTime();

    if (activeWorkTime == null) {
      throw Exception('Keine aktive Arbeitszeit gefunden');
    }

    final data = {
      'user_id': user.id,
      'work_time_id': activeWorkTime.id,
      'start_time': now.toIso8601String(),
      'date': today.toIso8601String().split('T')[0],
    };

    final response =
        await _supabase.from('breaks').insert(data).select().single();

    return Break.fromJson(response);
  }

  /// Beendet eine aktive Pause
  Future<Break> endBreak(String breakId) async {
    final now = DateTime.now().toUtc();

    final response =
        await _supabase
            .from('breaks')
            .update({'end_time': now.toIso8601String()})
            .eq('id', breakId)
            .select()
            .single();

    return Break.fromJson(response);
  }

  /// Holt alle Pausen für einen bestimmten Zeitraum
  Future<List<Break>> getBreaks({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Benutzer nicht authentifiziert');
    }

    final response = await _supabase
        .from('breaks')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    List<Break> breaks = response.map((json) => Break.fromJson(json)).toList();

    // Filter client-side
    if (startDate != null) {
      breaks =
          breaks
              .where(
                (b) =>
                    b.date.isAfter(startDate.subtract(const Duration(days: 1))),
              )
              .toList();
    }
    if (endDate != null) {
      breaks =
          breaks
              .where(
                (b) => b.date.isBefore(endDate.add(const Duration(days: 1))),
              )
              .toList();
    }

    return breaks;
  }

  /// Holt die aktuelle aktive Pause
  Future<Break?> getActiveBreak() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Benutzer nicht authentifiziert');
    }

    final response = await _supabase
        .from('breaks')
        .select()
        .eq('user_id', user.id)
        .order('start_time', ascending: false)
        .limit(10);

    // Filter client-side für aktive Pausen
    for (final json in response) {
      final breakItem = Break.fromJson(json);
      if (breakItem.endTime == null) {
        return breakItem;
      }
    }

    return null;
  }

  /// Aktualisiert eine Pause
  Future<Break> updateBreak(Break breakItem) async {
    final response =
        await _supabase
            .from('breaks')
            .update(breakItem.toJson())
            .eq('id', breakItem.id!)
            .select()
            .single();

    return Break.fromJson(response);
  }

  /// Löscht eine Pause
  Future<void> deleteBreak(String breakId) async {
    await _supabase.from('breaks').delete().eq('id', breakId);
  }

  /// Berechnet die Gesamtpausenzeit für einen Zeitraum
  Future<Duration> getTotalBreakTime({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final breaks = await getBreaks(startDate: startDate, endDate: endDate);

    Duration total = Duration.zero;
    for (final breakItem in breaks) {
      if (breakItem.endTime != null) {
        total += breakItem.endTime!.difference(breakItem.startTime);
      }
    }

    return total;
  }
}
