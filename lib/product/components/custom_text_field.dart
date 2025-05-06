import 'package:flutter/material.dart';
import 'package:flutter_word_game/feature/screens/login%20/forgot_password_page.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/texts/login_page_text.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.hasForgotPassword = false,
    required this.controller,
    this.errorText,
    this.suffixIcon, 
  });

  final String hintText;
  final bool isPassword;
  final bool hasForgotPassword;
  final TextEditingController controller;
  final String? errorText; 
  final IconData? suffixIcon; 

  //Box Decorationlar için ortak bir yapı oluşturdum.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PaddingUtils.mediumSymetric,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorUtils.loginWhite,
              border: Border.all(color: ColorUtils.loginWhite),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: PaddingUtils.xsOnly,
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  errorText: errorText,
                  suffixIcon:
                      suffixIcon != null
                          ? Icon(suffixIcon, color: Colors.grey)
                          : null,
                ),
              ),
            ),
          ),
          if (hasForgotPassword == true)
            Padding(
              padding: PaddingUtils.xsOnly,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ForgotPasswordPage();
                      },
                    ),
                  );
                },
                child: Text(
                  LoginPageTexts.forgotpassword,
                  style: TextStyle(
                    color: ColorUtils.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
