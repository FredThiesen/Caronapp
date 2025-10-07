import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';

import '../auth/login_sheet.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  void _showLoginSheet(BuildContext context, AuthMode mode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LoginSheet(initialMode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sky,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                'assets/logo.png',
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            const Text(
              'Caronas entre colegas, simples e seguras.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: 'Entrar',
                    onPressed: () => _showLoginSheet(context, AuthMode.signIn),
                    variant: AppButtonVariant.primary,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Criar conta',
                    onPressed: () => _showLoginSheet(context, AuthMode.signUp),
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
