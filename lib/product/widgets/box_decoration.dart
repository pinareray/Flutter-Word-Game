import 'package:flutter/material.dart';
import 'package:flutter_word_game/product/constants/color_utils.dart';

class GameStyledBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const GameStyledBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: ColorUtils.gameAmberBox,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: ColorUtils.gameOrangeShadow,
            blurRadius: 10,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
