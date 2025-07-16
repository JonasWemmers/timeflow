import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // ✅ Erfolgreich registriert
      if (mounted) {
        Navigator.pop(context); // Zurück zum Login nach erfolgreicher Registrierung
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Registrieren')),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoTextField(
                  controller: _emailController,
                  placeholder: 'E-Mail',
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Passwort',
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: CupertinoColors.systemRed),
                  ),
                if (_isLoading)
                  const CupertinoActivityIndicator()
                else
                  CupertinoButton.filled(
                    onPressed: _register,
                    child: const Text('Registrieren'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
