import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Initialisiert die Datenbank-Tabellen und Sicherheitsrichtlinien
  Future<void> initializeDatabase() async {
    try {
      // Prüfe ob Tabellen existieren, indem wir versuchen Daten zu lesen
      await _checkTablesExist();

      print('✅ Datenbank-Tabellen sind bereits vorhanden');
    } catch (e) {
      print('⚠️ Tabellen müssen manuell in Supabase erstellt werden');
      print(
        '📋 Bitte erstelle folgende Tabellen in deinem Supabase-Dashboard:',
      );
      print('''
      
=== WORK_TIMES TABLE ===
CREATE TABLE work_times (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

=== BREAKS TABLE ===
CREATE TABLE breaks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  work_time_id UUID REFERENCES work_times(id) ON DELETE CASCADE,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  date DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

=== HOLIDAYS TABLE ===
CREATE TABLE holidays (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

=== ROW LEVEL SECURITY ===
ALTER TABLE work_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE breaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE holidays ENABLE ROW LEVEL SECURITY;

=== POLICIES ===
-- Work Times Policies
CREATE POLICY "Users can view own work times" ON work_times FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own work times" ON work_times FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own work times" ON work_times FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own work times" ON work_times FOR DELETE USING (auth.uid() = user_id);

-- Breaks Policies
CREATE POLICY "Users can view own breaks" ON breaks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own breaks" ON breaks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own breaks" ON breaks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own breaks" ON breaks FOR DELETE USING (auth.uid() = user_id);

-- Holidays Policies
CREATE POLICY "Users can view own holidays" ON holidays FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own holidays" ON holidays FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own holidays" ON holidays FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own holidays" ON holidays FOR DELETE USING (auth.uid() = user_id);
      ''');
    }
  }

  /// Prüft ob die Tabellen existieren
  Future<void> _checkTablesExist() async {
    try {
      // Versuche eine leere Abfrage auf work_times
      await _supabase.from('work_times').select().limit(1);
    } catch (e) {
      throw Exception('Tabellen existieren nicht');
    }
  }
}
