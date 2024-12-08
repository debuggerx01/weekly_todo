import 'package:flutter/material.dart';

class DRadius {
  static final borderRadiusLarge = BorderRadius.circular(24);
  static final borderRadiusMedium = BorderRadius.circular(18);
  static final borderRadiusSmall = BorderRadius.circular(8);
}

class DColors {
  static const backgroundDeep = Color(0xff272727);
  static const backgroundNormal = Color(0xff2a2a2c);
  static const backgroundLight = Color(0xff323232);
  static const border = Color(0xFF3B3F43);
  static const secondaryText = Color(0xff7E8D99);
  static const barrier = Color(0x99363636);
  static const activeColor = Colors.blue;
  static const error = Colors.red;
}

class DSize {
  static const button = 46.0;
  static const icon = 32.0;
  static const inputFieldHeight = 52.0;
  static const windowPadding = 56.0;
  static const defaultPadding = 24.0;
  static const widgetPadding = 10.0;
  static const operationBtnSize = 64.0;
}

class DTextStyle {
  static const title = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 26,
  );

  static const subTitle = TextStyle(
    fontSize: 20,
  );

  static const normal = TextStyle(
    fontSize: 16,
  );
}
