import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeflow/constants/app_colors.dart';
import 'register_view_model.dart';

class RegisterView extends StatelessWidget {
  final bool showBackArrow;
  const RegisterView({super.key, this.showBackArrow = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: Center(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withAlpha((0.2 * 255).round()),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: viewModel.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Registrieren',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            if (viewModel.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(
                                      color: AppColors.error, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'E-Mail',
                                labelStyle:
                                    TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon:
                                    Icon(Icons.email, color: AppColors.primary),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte E-Mail eingeben';
                                }
                                if (!value.contains('@')) {
                                  return 'Bitte gültige E-Mail eingeben';
                                }
                                return null;
                              },
                              onChanged: (value) => viewModel.email = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Passwort',
                                labelStyle:
                                    TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon:
                                    Icon(Icons.lock, color: AppColors.primary),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte Passwort eingeben';
                                }
                                if (value.length < 6) {
                                  return 'Mindestens 6 Zeichen';
                                }
                                return null;
                              },
                              onChanged: (value) => viewModel.password = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Passwort bestätigen',
                                labelStyle:
                                    TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: AppColors.primary),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != viewModel.password) {
                                  return 'Passwörter stimmen nicht überein';
                                }
                                return null;
                              },
                              onChanged: (value) =>
                                  viewModel.confirmPassword = value,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () => viewModel.register(context),
                                child: viewModel.isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Registrieren',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showBackArrow)
                      Positioned(
                        top: 8,
                        left: 32,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: AppColors.primary,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
