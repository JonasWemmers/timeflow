import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/work_time.dart';

class WorkTimeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Startet eine neue Arbeitszeit
  Future<WorkTime> startWorkTime() async {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Benutzer nicht authentifiziert');
    }

    final data = {
      'user_id': user.id,
      'start_time': now.toIso8601String(),
      'date': today.toIso8601String().split('T')[0],
    };

    final response =
        await _supabase.from('work_times').insert(data).select().single();

    return WorkTime.fromJson(response);
  }

  /// Beendet eine aktive Arbeitszeit
  Future<WorkTime> endWorkTime(String workTimeId) async {
    final now = DateTime.now().toUtc();

    final response =
        await _supabase
            .from('work_times')
            .update({'end_time': now.toIso8601String()})
            .eq('id', workTimeId)
            .select()
            .single();

    return WorkTime.fromJson(response);
  }

  /// Holt alle Arbeitszeiten für einen bestimmten Zeitraum
  Future<List<WorkTime>> getWorkTimes({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Benutzer nicht authentifiziert');
    }

    final response = await _supabase
        .from('work_times')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: false);

    List<WorkTime> workTimes =
        response.map((json) => WorkTime.fromJson(json)).toList();

    // Filter client-side für bessere Kompatibilität
    if (startDate != null) {
      workTimes =
          workTimes
              .where(
                (wt) => wt.date.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ),
              )
              .toList();
    }
    if (endDate != null) {
      workTimes =
          workTimes
              .where(
                (wt) => wt.date.isBefore(endDate.add(const Duration(days: 1))),
              )
              .toList();
    }

    return workTimes;
  }

  /// Holt die aktuelle aktive Arbeitszeit
  Future<WorkTime?> getActiveWorkTime() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Benutzer nicht authentifiziert');
    }

    final response = await _supabase
        .from('work_times')
        .select()
        .eq('user_id', user.id)
        .order('start_time', ascending: false)
        .limit(10);

    // Filter client-side für aktive Arbeitszeiten
    for (final json in response) {
      final workTime = WorkTime.fromJson(json);
      if (workTime.endTime == null) {
        return workTime;
      }
    }

    return null;
  }

  /// Aktualisiert eine Arbeitszeit
  Future<WorkTime> updateWorkTime(WorkTime workTime) async {
    final response =
        await _supabase
            .from('work_times')
            .update(workTime.toJson())
            .eq('id', workTime.id!)
            .select()
            .single();

    return WorkTime.fromJson(response);
  }

  /// Löscht eine Arbeitszeit
  Future<void> deleteWorkTime(String workTimeId) async {
    await _supabase.from('work_times').delete().eq('id', workTimeId);
  }

  /// Berechnet die Gesamtarbeitszeit für einen Zeitraum
  Future<Duration> getTotalWorkTime({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final workTimes = await getWorkTimes(
      startDate: startDate,
      endDate: endDate,
    );

    Duration total = Duration.zero;
    for (final workTime in workTimes) {
      if (workTime.endTime != null) {
        total += workTime.endTime!.difference(workTime.startTime);
      }
    }

    return total;
  }
}
