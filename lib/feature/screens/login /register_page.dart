// GÜNCELLENMİŞ RegisterPage (register_page.dart)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/components/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:flutter_word_game/product/constants/texts/register_page_text.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

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
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$").hasMatch(email);
  }

  Future signUp() async {
    final email = _emailController.text.trim();
    final userName = _userNameController.text.trim();
    final password = _passwordController.text.trim();

    if (userName.isEmpty) {
      _showDialog('Eksik Bilgi', 'Kullanıcı adı boş olamaz.');
      return;
    }

    if (!isValidEmail(email)) {
      _showDialog(
        'Geçersiz E-posta',
        'Lütfen geçerli bir e-posta adresi girin.',
      );
      return;
    }

    if (password.length < 6) {
      _showDialog('Zayıf Şifre', 'Şifre en az 6 karakter olmalıdır.');
      return;
    }

    if (!passwordConfirmed()) {
      _showDialog('Şifre Hatası', 'Şifreler uyuşmuyor.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Kullanıcı bilgilerini Firestore'a kaydet
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userID': uid,
        'userName': userName,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      _showDialog('Başarılı', 'Kayıt başarıyla tamamlandı.');

      Future.delayed(const Duration(seconds: 2), () {
        widget.showLoginPage();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showDialog('Kayıt Hatası', 'Bu e-posta adresi zaten kullanımda.');
      } else {
        _showDialog('Hata', e.message ?? 'Bilinmeyen bir hata oluştu.');
      }
    } catch (e) {
      print("Genel Hata: \$e");
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
                child: const Text("Tamam"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
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
                Icon(Icons.create, size: Numbers.xLarge),
                Text(
                  RegisterPageText.newAccountMessage,
                  style: GoogleFonts.fahkwang(fontSize: Numbers.medium),
                ),
                SizedBoxUtils.smallBox,
                Text(
                  RegisterPageText.subMessage,
                  style: const TextStyle(fontSize: Numbers.small),
                  textAlign: TextAlign.center,
                ),
                SizedBoxUtils.smallBox,
                CustomTextField(
                  hintText: AppTexts.userName,
                  controller: _userNameController,
                  suffixIcon: Icons.person,
                ),
                SizedBoxUtils.smallBox,
                CustomTextField(
                  hintText: AppTexts.email,
                  controller: _emailController,
                  suffixIcon: Icons.email,
                ),
                SizedBoxUtils.smallBox,
                CustomTextField(
                  hintText: AppTexts.password,
                  controller: _passwordController,
                  isPassword: true,
                  suffixIcon: Icons.lock,
                ),
                SizedBoxUtils.smallBox,
                CustomTextField(
                  hintText: RegisterPageText.confirmPassword,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  suffixIcon: Icons.lock,
                ),
                SizedBoxUtils.mediumBox,
                Padding(
                  padding: PaddingUtils.xLargeHorizontal,
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: PaddingUtils.smallAll,
                      decoration: BoxDecoration(
                        color: ColorUtils.lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          RegisterPageText.signUpMessage,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Numbers.small,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(RegisterPageText.loginQuestionMessage),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        AppTexts.signInText,
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
