import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double scaleWidth;
  static late double scaleHeight;
  static late double textScale;

  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(
    BuildContext context, {
    double designWidth = 360,
    double designHeight = 690,
  }) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    scaleWidth = screenWidth / designWidth;
    scaleHeight = screenHeight / designHeight;
    textScale = scaleWidth; // Use width for text scaling

    final safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    final safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  static double w(double inputWidth) => inputWidth * scaleWidth;
  static double h(double inputHeight) => inputHeight * scaleHeight;
  static double sp(double fontSize) => fontSize * textScale;
}
