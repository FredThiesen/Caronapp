import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_input.dart';
import '../../shared/mocks/mock_user.dart';
import '../home/home_screen.dart';

enum AuthMode { signIn, signUp }

class LoginSheet extends StatefulWidget {
  final AuthMode initialMode;
  const LoginSheet({super.key, this.initialMode = AuthMode.signIn});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
      _error = null;
    });
  }

  void _submit() {
    setState(() {
      _error = null;
      _loading = true;
    });
    if (_formKey.currentState?.validate() ?? false) {
      // Simula sucesso
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(user: mockUser)),
        );
      });
    } else {
      setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Informe o email';
    if (!value.contains('@')) return 'Email inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateRepeatPassword(String? value) {
    if (_mode == AuthMode.signUp && value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == AuthMode.signUp;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isSignUp ? 'Criar conta' : 'Entrar',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppInput(
                      label: 'Email',
                      hint: 'use o institucional',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    AppInput(
                      label: 'Senha',
                      obscureText: true,
                      controller: _passwordController,
                      validator: _validatePassword,
                    ),
                    if (isSignUp)
                      AppInput(
                        label: 'Repita sua senha',
                        obscureText: true,
                        controller: _repeatPasswordController,
                        validator: _validateRepeatPassword,
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: isSignUp ? 'Cadastrar' : 'Entrar',
                      onPressed: _loading ? null : _submit,
                      variant: AppButtonVariant.primary,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _loading ? null : _toggleMode,
                      child: Text(
                        isSignUp
                            ? 'Já tem conta? Entrar'
                            : 'Não tem conta? Criar conta',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
