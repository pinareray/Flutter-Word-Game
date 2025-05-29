import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/widgets/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text(ForgotPasswordTexts.resetSuccess));
        },
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.message ?? ForgotPasswordTexts.resetError),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.gameYellow, // Arka plan sarı
      appBar: AppBar(
        backgroundColor: ColorUtils.gameYellow,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorUtils.gameAmberBox,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                const BoxShadow(
                  color: ColorUtils.gameOrangeShadow,
                  blurRadius: 10,
                  offset: Offset(4, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ForgotPasswordTexts.pageInstruction,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: AppSpacing.md,
                    color: ColorUtils.gameBrownText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSizedBoxes.sm,

                CustomTextField(
                  hintText: AppTexts.email,
                  controller: _emailController,
                  suffixIcon: Icons.email,
                ),

                AppSizedBoxes.md,

                MaterialButton(
                  onPressed: passwordReset,
                  color: ColorUtils.gameDeepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  child: Text(
                    ForgotPasswordTexts.resetButton,
                    style: GoogleFonts.fredoka(
                      fontSize: AppSpacing.sm,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
