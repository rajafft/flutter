import 'package:flutter/widgets.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData =  MediaQueryData();
  static double screenWidth = 0.0;
  static double screenHeight = 0.0;
  static double blockSizeHorizontal = 0.0;
  static double blockSizeVertical = 0.0;
  static double _safeAreaHorizontal = 0.0;
  static double _safeAreaVertical = 0.0;
  static double safeBlockHorizontal = 0.0;
  static double safeBlockVertical = 0.0;

  //for font sizing
  static double verySmall = 0.0;
  static double small = 0.0;
  static double medium = 0.0;
  static double large = 0.0;
  static double xlarge = 0.0;
  static double xxlarge = 0.0;
  static double heading = 0.0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    verySmall = blockSizeHorizontal * 3;
    small = blockSizeHorizontal * 3.5;
    medium = blockSizeHorizontal * 4;
    heading = blockSizeHorizontal * 4.5;
    large = blockSizeHorizontal * 5;
    xlarge = blockSizeHorizontal * 6;
    xxlarge = blockSizeHorizontal * 7;
  }
}

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context,
    {double dividedBy = 1, double reducedBy = 0.0}) {
  return (screenSize(context).height - reducedBy) / dividedBy;
}

double screenWidth(BuildContext context,
    {double dividedBy = 1, double reducedBy = 0.0}) {
  return (screenSize(context).width - reducedBy) / dividedBy;
}
