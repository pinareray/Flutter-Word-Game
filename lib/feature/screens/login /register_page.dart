import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/widgets/box_decoration.dart';
import 'package:flutter_word_game/product/widgets/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage; //Giriş sayfasına geçmek için kullanırız.
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

//Kullanıcıdan aldığımız verileri kontrol ediyoruz.
class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  Future signUp() async {
    final email = _emailController.text.trim();
    final userName = _userNameController.text.trim();
    final password = _passwordController.text.trim();

    if (userName.isEmpty) {
      _showDialog(
        RegisterPageText.emptyUsernameTitle,
        RegisterPageText.emptyUsernameMessage,
      );
      return;
    }

    if (!isValidEmail(email)) {
      _showDialog(
        LoginPageTexts.invalidEmail,
        LoginPageTexts.invalidEmailMessage,
      );
      return;
    }

    if (password.length < 6) {
      _showDialog(AppTexts.weakPassword, RegisterPageText.shortPasswordMessage);
      return;
    }

    if (!passwordConfirmed()) {
      _showDialog(
        RegisterPageText.passwordMismatchTitle,
        RegisterPageText.passwordMismatchMessage,
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userID': uid,
        'userName': userName,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      _showDialog(AppTexts.succesful, RegisterPageText.succesfulMessage);

      Future.delayed(const Duration(seconds: 2), () {
        widget.showLoginPage();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showDialog(
          LoginPageTexts.registrationError,
          RegisterPageText.existingEmail,
        );
      } else {
        _showDialog(
          LoginPageTexts.error,
          e.message ?? LoginPageTexts.unkownError,
        );
      }
    } catch (e) {
      print("Genel Hata: $e");
    }
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
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
                    Icons.create,
                    size: AppSpacing.xl,
                    color: Colors.deepOrange,
                  ),
                  Text(
                    RegisterPageText.newAccountMessage,
                    style: GoogleFonts.fredoka(
                      fontSize: AppSpacing.md,
                      fontWeight: FontWeight.w600,
                      color: ColorUtils.gameBrownText,
                    ),
                  ),
                  AppSizedBoxes.sm,
                  const Text(
                    RegisterPageText.subMessage,
                    style: TextStyle(
                      fontSize: AppSpacing.sm,
                      color: ColorUtils.gameBrownText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSizedBoxes.sm,
                  CustomTextField(
                    hintText: AppTexts.userName,
                    controller: _userNameController,
                    suffixIcon: Icons.person,
                  ),
                  AppSizedBoxes.sm,
                  CustomTextField(
                    hintText: AppTexts.email,
                    controller: _emailController,
                    suffixIcon: Icons.email,
                  ),
                  AppSizedBoxes.sm,
                  CustomTextField(
                    hintText: AppTexts.password,
                    controller: _passwordController,
                    isPassword: true,
                    suffixIcon: Icons.lock,
                  ),
                  AppSizedBoxes.sm,
                  CustomTextField(
                    hintText: RegisterPageText.confirmPassword,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    suffixIcon: Icons.lock,
                  ),
                  AppSizedBoxes.md,
                  Padding(
                    padding: AppPaddings.xLargeHorizontal,
                    child: GestureDetector(
                      onTap: signUp,
                      child: Container(
                        padding: AppPaddings.smAll,
                        decoration: BoxDecoration(
                          color: ColorUtils.gameDeepOrange,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: ColorUtils.gameOrangeShadow,
                              blurRadius: 6,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            RegisterPageText.signUpMessage,
                            style: GoogleFonts.fredoka(
                              fontSize: AppSpacing.sm,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                        RegisterPageText.loginQuestionMessage,
                        style: TextStyle(color: ColorUtils.gameBrownText),
                      ),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: const Text(
                          AppTexts.signInText,
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
