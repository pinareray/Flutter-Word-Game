import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/feature/screens/login%20/login_page.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;

        return AnimatedSplashScreen(
          splash: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.4,
                child: Lottie.asset('assets/Animation_splash_screen.json'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kelime Oyununa Hoşgeldiniz',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ],
          ),
          nextScreen: LoginPage(showRegisterPage: () {}),
          splashIconSize: screenHeight * 0.6,
          duration: 3000,
          splashTransition: SplashTransition.fadeTransition,
        );
      },
    );
  }
}
