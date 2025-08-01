import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  ProfileViewModel() {
    // Initialisiere sofort beim Erstellen
    _initializeData();
  }

  void _initializeData() {
    // Verzögerte Initialisierung um sicherzustellen, dass Supabase bereit ist
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_initialized) {
        loadUserData();
      }
    });
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lädt die Benutzerdaten
  Future<void> loadUserData() async {
    if (_isLoading || _initialized) return; // Verhindert mehrfache Aufrufe

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Prüfe ob Supabase initialisiert ist
      if (_supabase.auth.currentUser == null) {
        // Warte kurz und versuche es nochmal
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _currentUser = _supabase.auth.currentUser;
      if (_currentUser == null) {
        _errorMessage = 'Kein Benutzer angemeldet';
      }
      _initialized = true;
    } catch (e) {
      _errorMessage = 'Fehler beim Laden der Benutzerdaten: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Meldet den Benutzer ab
  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      return true;
    } catch (e) {
      _errorMessage = 'Fehler beim Abmelden: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Löscht Fehlermeldungen
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Erzwingt eine Neuinitialisierung
  void reset() {
    _initialized = false;
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
