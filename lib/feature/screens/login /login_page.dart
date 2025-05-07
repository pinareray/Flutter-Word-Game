import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/components/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/texts/login_page_text.dart';
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
              title: Text(LoginPageTexts.errorTitle),
              content: Text(message),
              actions: [
                TextButton(
                  child: Text(LoginPageTexts.okButton),
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
      backgroundColor: ColorUtils.roguePink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_sharp, size: Numbers.xLarge),
                Text(
                  LoginPageTexts.welcomeMessage,
                  style: GoogleFonts.fahkwang(fontSize: Numbers.mediumTree),
                ),
                SizedBoxUtils.smallBox,
                Text(
                  LoginPageTexts.subMessage,
                  style: TextStyle(fontSize: Numbers.small),
                  textAlign: TextAlign.center,
                ),
                SizedBoxUtils.smallBox,

                // Kullanıcı adı textfield
                CustomTextField(
                  controller: _userNameController,
                  hintText: LoginPageTexts.userNameOrEmail,
                  suffixIcon: Icons.email,
                ),
                SizedBoxUtils.smallBox,

                // Şifre textfield + "Şifremi Unuttum"
                CustomTextField(
                  controller: _passwordController,
                  hintText: AppTexts.password,
                  isPassword: true,
                  hasForgotPassword: true,
                  suffixIcon: Icons.lock,
                ),

                SizedBoxUtils.mediumBox,

                //Giriş yap butonu
                Padding(
                  padding: PaddingUtils.xLargeHorizontal,
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: PaddingUtils.smallAll,
                      decoration: BoxDecoration(
                        color: ColorUtils.lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          AppTexts.signInText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Numbers.small,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                //Hesap yoksa kaydolun.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LoginPageTexts.signUpQuestionText),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        LoginPageTexts.signUpText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorUtils.belizeHole,
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
    );
  }
}
