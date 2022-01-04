import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wean_app/common/appTheme.dart';

BoxDecoration pinDecoration = BoxDecoration(
  // color: AppTheme.primaryDimColor,
  // borderRadius: BorderRadius.circular(5.0),
  border: Border(
    bottom: BorderSide(
      color: Colors.black,
    ),
  ),
);

OutlineInputBorder normalBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AppTheme.greyText),
  borderRadius: const BorderRadius.all(
    const Radius.circular(10.0),
  ),
);

OutlineInputBorder focusBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AppTheme.primaryColor),
  borderRadius: const BorderRadius.all(
    const Radius.circular(10.0),
  ),
);

//shadow decoration
BoxDecoration cardShadowDecoration = BoxDecoration(
  boxShadow: [
    new BoxShadow(
      color: Colors.grey.shade300,
      blurRadius: 10.0,
    ),
  ],
);

BoxDecoration outlineBoxDecoration = BoxDecoration(
  border: Border.all(
    color: AppTheme.primaryColor, //                   <--- border color
    width: 1.0,
  ),
);

BoxDecoration roundedOutlineBox = BoxDecoration(
  color: Colors.white,
  borderRadius: const BorderRadius.all(
    const Radius.circular(10.0),
  ),
  border: Border.all(
    color: AppTheme.greyText, //                   <--- border color
    width: 1.0,
  ),
);

// TODO: background must be white
BoxDecoration whiteBox = BoxDecoration(
  color: Colors.white,
  borderRadius: const BorderRadius.all(
    const Radius.circular(10.0),
  ),
);
