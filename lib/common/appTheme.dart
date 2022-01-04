import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const Color primaryColor = Color(0xFFffbd2d);
  static const Color primaryBColor = Color(0xfff8b421);
  static const Color primaryStartColor =  Color(0xffffF4B846);
  static const Color primaryLightColor = Color(0xfffecc60);
  static const Color primaryDimColor = Color(0xfffbeccd);
  static const Color primaryDarkColor = Color(0xffDB9818);
  static const Color layoutBg = Color(0xfffefbf8);
  static const Color navBarColor = Colors.white;
  // static const Color navBarColor = Color(0xfff4fbfe);
  // ? Base Grey Colors
  static const Color disable = Color(0xffcccccc);
  static const Color warmGrey = Color(0xff757575);
  static const Color quesGrey = Color(0xfff8f8f8);
  static const Color progressGrey = Color(0xffe5e5e5);
  // ? End of Base Grey Colos

  // ? Standard colors
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);
// ? End of standard colors

  // ? Text Colors
  static const Color baseText = Color(0xff171717);
  static const Color greyText = Color(0xff757575);
  static const Color disableColor = Color(0xff8f92a1);

  static const TextTheme textTheme = TextTheme(
      headline1: h1, // big text
      headline2: h2, // medium
      headline3: h3, // regular
      headline4: h4,
      headline5: h5,
      bodyText1: body1, // p pink
      bodyText2: body2, // p
      button: button, // button
      caption: disabled // disabled text
      );

  static const TextStyle h1 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 26.0,
    color: baseText,
  );

  static const TextStyle h2 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: baseText,
  );

  static const TextStyle h3 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    color: Colors.black45,
  );

  static const TextStyle h4 = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20.0,
    color: black,
  );

  static const TextStyle h5 = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18.0,
    color: Colors.black,
  );

  static const TextStyle body1 = TextStyle(
      fontWeight: FontWeight.w400, fontSize: 14.0, color: AppTheme.white);

  static const TextStyle body2 =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0, color: baseText);

  static const TextStyle disabled =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0, color: baseText);

  static const TextStyle button = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
    color: black,
  );
  static ButtonStyle flatButtonStyle = ElevatedButton.styleFrom(
      primary: primaryColor, alignment: Alignment.center);

  static final ThemeData appThemeData = ThemeData(
    // scaffoldBackgroundColor: layoutBg,
    fontFamily: 'avenir',
    // fontFamily: 'calibri_regular',
    primaryColor: primaryColor,
    dividerColor: greyText,
    disabledColor: greyText,
    appBarTheme: AppBarTheme(
        color: primaryColor, iconTheme: IconThemeData(color: white)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
    ),
  );
}
