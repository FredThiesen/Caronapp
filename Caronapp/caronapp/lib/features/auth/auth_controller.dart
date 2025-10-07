import 'package:flutter/material.dart';

enum AuthMode { signIn, signUp }

class AuthController extends ChangeNotifier {
  AuthMode mode;
  AuthController({this.mode = AuthMode.signIn});

  void toggleMode() {
    mode = mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
    notifyListeners();
  }
}
