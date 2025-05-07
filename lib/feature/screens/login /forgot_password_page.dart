import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/components/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:flutter_word_game/product/constants/texts/login_page_text.dart'; // 🔹 yeni eklenen metin dosyası

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
      backgroundColor: ColorUtils.roguePink,
      appBar: AppBar(backgroundColor: ColorUtils.roguePink, elevation: 0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ForgotPasswordTexts.pageInstruction,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: Numbers.medium),
          ),
          SizedBoxUtils.smallBox,
          CustomTextField(
            hintText: AppTexts.email,
            controller: _emailController,
            suffixIcon: Icons.email,
          ),
          SizedBoxUtils.smallBox,
          MaterialButton(
            onPressed: passwordReset,
            child: Text(ForgotPasswordTexts.resetButton),
            color: ColorUtils.lightBlue,
          ),
        ],
      ),
    );
  }
}
