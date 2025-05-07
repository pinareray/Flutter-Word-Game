import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/core/services/auth_page.dart';
import 'package:flutter_word_game/feature/screens/home_page.dart';
import 'package:flutter_word_game/feature/screens/login%20/login_page.dart';
import 'package:flutter_word_game/feature/screens/login%20/register_page.dart';
import 'package:flutter_word_game/feature/screens/login%20/splash_page.dart';

class AuthService extends StatelessWidget {
  const AuthService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else
            return AuthPage();
        },
      ),
    );
  }
}
