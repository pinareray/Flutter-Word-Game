import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/components/custom_text_field.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/texts/app_text.dart';
import 'package:flutter_word_game/product/constants/texts/login_page_text.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';
import 'package:flutter_word_game/product/constants/texts/register_page_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // utf8.encode için

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
    _userNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Email format doğrulama
  bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  // Kayıt ol buton yönetimi, burada kullanıcı kimliğini doğrulayıp yaratıyoruz.
Future signUp() async {
  final email = _emailController.text.trim();

  // Email geçerliliğini kontrol ediyoruz
  if (!isValidEmail(email)) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(RegisterPageText.invalidEmailTitle), 
        content: Text(RegisterPageText.invalidEmailMessage), 
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Tamam"),
          ),
        ],
      ),
    );
    return;
  }

  if (!passwordConfirmed()) return;

  try {
    // Auth ile kullanıcı oluşturdum
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // UID aldık
    String uid = userCredential.user!.uid;

    // Firestore'a kullanıcı kaydettik
    await addUserDetails(
      uid,
      _userNameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(), 
    );

    print("Kullanıcı başarıyla Firestore'a eklendi!");
  } catch (e) {
    print("HATA: $e");
  }
}


  // Firestore'a kullanıcı detaylarını eklemek için (şifreyi hashledim)
  Future addUserDetails(
    String uid,
    String userName,
    String email,
    String password,
  ) async {
    // Şifreyi SHA256 ile hashledim
    String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'userID': uid,
      'userName': userName,
      'email': email,
      'password': hashedPassword,
      'createdAt': Timestamp.now(),
    });
  }

  // Girilen şifreler uyuşuyor mu kontrol ediyoruz
  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
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
                  style: TextStyle(fontSize: Numbers.small),
                  textAlign: TextAlign.center,
                ),
                SizedBoxUtils.smallBox,
                // Kullanıcı adı kutusu
                CustomTextField(
                  hintText: AppTexts.userName,
                  controller: _userNameController,
                  suffixIcon: Icons.person,
                ),
                SizedBoxUtils.smallBox,
                // Email kutusu
                CustomTextField(
                  hintText: AppTexts.email,
                  controller: _emailController,
                  suffixIcon: Icons.email,
                ),
                SizedBoxUtils.smallBox,
                // Şifre kutusu
                CustomTextField(
                  hintText: AppTexts.password,
                  controller: _passwordController,
                  isPassword: true,
                  suffixIcon: Icons.lock,
                ),
                SizedBoxUtils.smallBox,
                // Şifre tekrar kutusu
                CustomTextField(
                  hintText: RegisterPageText.confirmPassword,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  suffixIcon: Icons.lock,
                ),
                SizedBoxUtils.mediumBox,
                // Kayıt ol butonu
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Numbers.small,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Zaten hesap varsa giriş ekranına dön
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
