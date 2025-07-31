import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setEmail(String email) {
    _email = email;
  }

  void setPassword(String password) {
    _password = password;
  }

  Future<void> login(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await supabase.auth.signInWithPassword(
        email: _email.trim(),
        password: _password,
      );

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Unbekannter Fehler: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
