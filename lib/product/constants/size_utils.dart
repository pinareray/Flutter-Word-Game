import 'package:flutter/widgets.dart';

class AppSpacing {
  static const double xs = 5;
  static const double xs1 = 10;
  static const double sm = 15;
  static const double md = 20;
  static const double md2 = 25;
  static const double md3 = 35;
  static const double md4 = 40;
  static const double lg = 50;
  static const double xl = 100;
}

class AppSizedBoxes {
  static final SizedBox xs = const SizedBox(height: AppSpacing.xs);
  static final SizedBox xs1 = const SizedBox(height: AppSpacing.xs1);
  static final SizedBox sm = const SizedBox(height: AppSpacing.sm);
  static final SizedBox md = const SizedBox(height: AppSpacing.md);
  static final SizedBox md3 = const SizedBox(height: AppSpacing.md3);
  static final SizedBox lg = const SizedBox(height: AppSpacing.lg);
}

class AppPaddings {
  static final EdgeInsets xsLeft = const EdgeInsets.only(left: AppSpacing.xs);
  static final EdgeInsets mdHorizontal = const EdgeInsets.symmetric(
    horizontal: AppSpacing.md2,
  );
  static final EdgeInsets xLargeHorizontal = const EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
  );
  static final EdgeInsets smAll = const EdgeInsets.all(AppSpacing.sm);
    static final EdgeInsets mdAll = const EdgeInsets.all(AppSpacing.md);
      static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(vertical: 12, horizontal: 24);
}
