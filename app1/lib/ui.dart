import 'package:flutter/material.dart';

//image
class AppImages {
  static final String imagePath = "assets/images/";
  static final String nature = imagePath + "nature.jpg";
  static final String nature2 = imagePath + "nature2.jpg";
}

//font
class AppFonts {
  static const String dancing = "Dancing";
}

//color
class AppColors {
  static const Color primaryColor = Color(0xffABC4FF);
  static const Color backgroundColor = Color(0xffEDF2FB);
}

//style
class AppStyles {
  static const TextStyle h2 = TextStyle(
    fontSize: 40,
    fontFamily: AppFonts.dancing,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 32,
    fontFamily: AppFonts.dancing,
  );
  static const TextStyle h4 = TextStyle(
    fontSize: 26,
    fontFamily: AppFonts.dancing,
  );
  static const TextStyle h6 = TextStyle(
    fontSize: 22,
    fontFamily: AppFonts.dancing,
  );
  static const TextStyle h5 = TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.dancing,
  );
}
