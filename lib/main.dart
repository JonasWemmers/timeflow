import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeflow/routes/app_router.dart';
import 'package:timeflow/routes/app_routes.dart';
import 'package:timeflow/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rpfluuchvsrcnwkqxvku.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwZmx1dWNodnNyY253a3F4dmt1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NjU2MjgsImV4cCI6MjA2OTU0MTYyOH0.jX1bo0uxblOvbbxYB7dmZM54BQnEslqDgBw9d-1Utnk',
  );

  // Initialisiere Datenbank-Tabellen und Sicherheitsrichtlinien
  try {
    final databaseService = DatabaseService();
    await databaseService.initializeDatabase();
  } catch (e) {
    print('⚠️ Datenbank-Initialisierung fehlgeschlagen: $e');
    // App läuft trotzdem weiter, da Tabellen möglicherweise bereits existieren
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
