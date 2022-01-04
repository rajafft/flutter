import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wean_app/common/appTheme.dart';
class TextTitle extends StatelessWidget {
  final String text;
  final double textSize;
  final Color textColor;

  TextTitle(
      {required this.text, this.textSize = 14, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        toBeginningOfSentenceCase(text)!,
        style: TextStyle(
            fontWeight: FontWeight.bold, color: textColor, fontSize: textSize, letterSpacing: 1.5),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class TextNormal extends StatelessWidget {
  final String text;
  final double textSize;
  final Color textColor;

  TextNormal(
      {required this.text,
      this.textSize = 12.0,
      this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: textColor,
          fontSize: textSize,
          letterSpacing: 1.5
        ),
      ),
    );
  }
}

class TextAppName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: RichText(
        text: TextSpan(
            text: "W",
            style: TextStyle(
                color: AppTheme.white, fontFamily: 'harlow', fontSize: 26, letterSpacing: 1.0),
            children: [
              TextSpan(
                text: "aen",
                style: TextStyle(
                  color: AppTheme.white,
                  fontFamily: 'calibri_bold',
                  fontSize: 24,
                  letterSpacing: 1.0
                ),
              )
            ]),
      ),
    );
  }
}
