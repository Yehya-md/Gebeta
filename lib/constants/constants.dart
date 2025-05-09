import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const primaryColor = Color(0xFF2E3192);
  static const backgroundColor = Color.fromRGBO(245, 245, 245, 1);
  static const textColor = Color(0xFF424242);
  static const secondaryTextColor = Color(0xFF757575);
  static const errorColor = Colors.red;
  static const favoriteColor = Colors.red;
  static const white = Colors.white;
  static const grey = Colors.grey;

  // Text Styles
  static const headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  static const headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  static const headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  static const bodyText1 = TextStyle(
    fontSize: 16,
    color: textColor,
    height: 1.5,
  );
  static const bodyText2 = TextStyle(
    fontSize: 14,
    color: secondaryTextColor,
  );
  static const buttonText = TextStyle(
    fontSize: 16,
    color: white,
  );

  // Paddings and Margins
  static const defaultPadding = EdgeInsets.all(16.0);
  static const buttonPadding =
      EdgeInsets.symmetric(horizontal: 32, vertical: 12);
  static const fabMargin = EdgeInsets.only(bottom: 8.0);

  // Border Radii
  static const cardBorderRadius = BorderRadius.all(Radius.circular(10));
  static const buttonBorderRadius = BorderRadius.all(Radius.circular(15));

  // Icons
  static const iconSize = 24.0;
  static const fabIconSize = 36.0;
}
