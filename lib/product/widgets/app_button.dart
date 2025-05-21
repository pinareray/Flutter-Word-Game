import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';
import 'package:flutter_word_game/product/constants/size_utils.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.padding,
    this.textStyle,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final btnTextStyle =
        textStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? ColorUtils.purpleStatistic,
        padding: padding ?? AppPaddings.buttonPadding,
        textStyle: btnTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
