import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/widgets/box_decoration.dart';
import 'package:flutter_word_game/product/widgets/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _userNameController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'user-not-found':
          message = LoginPageTexts.userNotFound;
          break;
        case 'wrong-password':
          message = LoginPageTexts.wrongPassword;
          break;
        case 'invalid-email':
          message = LoginPageTexts.invalidEmail;
          break;
        default:
          message = LoginPageTexts.generalError;
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(LoginPageTexts.errorTitle),
              content: Text(message),
              actions: [
                TextButton(
                  child: const Text(LoginPageTexts.okButton),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.gameYellow,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: GameStyledBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle_sharp,
                    size: AppSpacing.xl,
                    color: ColorUtils.gameDeepOrange,
                  ),
                  Text(
                    LoginPageTexts.welcomeMessage,
                    style: GoogleFonts.fredoka(
                      fontSize: AppSpacing.md4,
                      fontWeight: FontWeight.w600,
                      color: ColorUtils.gameBrownText,
                    ),
                  ),
                  AppSizedBoxes.sm,
                  const Text(
                    LoginPageTexts.subMessage,
                    style: TextStyle(
                      fontSize: AppSpacing.sm,
                      color: Colors.brown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSizedBoxes.md,
                  CustomTextField(
                    controller: _userNameController,
                    hintText: AppTexts.email,
                    suffixIcon: Icons.email,
                  ),
                  AppSizedBoxes.sm,
                  CustomTextField(
                    controller: _passwordController,
                    hintText: AppTexts.password,
                    isPassword: true,
                    hasForgotPassword: true,
                    suffixIcon: Icons.lock,
                  ),
                  AppSizedBoxes.md,
                  Padding(
                    padding: AppPaddings.xLargeHorizontal,
                    child: GestureDetector(
                      onTap: signIn,
                      child: Container(
                        padding: AppPaddings.smAll,
                        decoration: BoxDecoration(
                          color: ColorUtils.gameDeepOrange,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.shade200,
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            AppTexts.signInText,
                            style: GoogleFonts.fredoka(
                              fontSize: AppSpacing.sm,
                              fontWeight: FontWeight.bold,
                              color: ColorUtils.loginWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSizedBoxes.sm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        LoginPageTexts.signUpQuestionText,
                        style: TextStyle(color: ColorUtils.gameBrownText),
                      ),
                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: const Text(
                          LoginPageTexts.signUpText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorUtils.gamePurpleAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
