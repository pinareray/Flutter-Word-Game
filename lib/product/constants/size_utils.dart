import 'package:flutter/widgets.dart';

class Numbers {
  static const double xSmall = 5;
  static const double small = 15;
  static const double medium = 20;
  static const double mediumTwo = 25;
  static const double mediumTree = 40;
  static const double large = 50;
  static const double xLarge = 100;
}

class SizedBoxUtils {
  static final SizedBox xSmallBox = SizedBox(height: Numbers.xSmall);
  static final SizedBox smallBox = SizedBox(height: Numbers.small);
  static final SizedBox mediumBox = SizedBox(height: Numbers.medium);
  static final SizedBox largeBox = SizedBox(height: Numbers.large);
}

class PaddingUtils {
  static final EdgeInsets xsOnly = EdgeInsets.only(left: Numbers.xSmall);
  static final EdgeInsets mediumSymetric = EdgeInsets.symmetric(
    horizontal: Numbers.mediumTwo,
  );
  static final EdgeInsets xLargeHorizontal = EdgeInsets.symmetric(
    horizontal: Numbers.xLarge,
  );
  static final EdgeInsets smallAll = EdgeInsets.all(Numbers.small);
}
