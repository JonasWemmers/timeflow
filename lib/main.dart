import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeflow/routes/app_router.dart';
import 'package:timeflow/routes/app_routes.dart';
import 'package:timeflow/services/database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lade Umgebungsvariablen
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
