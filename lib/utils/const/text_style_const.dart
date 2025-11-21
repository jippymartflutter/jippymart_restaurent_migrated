import 'package:flutter/cupertino.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';

class TextStyleConst{
  static TextStyle  whiteMedium18 = TextStyle(color: ColorConst.white,fontSize: 18,);
  static TextStyle  whiteMedium15 = TextStyle(color: ColorConst.white,fontSize: 15,
    fontFamily: AppThemeData.medium,fontWeight: FontWeight.bold,);
  static TextStyle  yellowMedium15 = TextStyle(color: ColorConst.yellow,fontSize: 15,
    fontWeight: FontWeight.bold,fontFamily: AppThemeData.medium,);
  static TextStyle  blueMedium15 = TextStyle(color: ColorConst.blue,fontSize: 15,
    fontWeight: FontWeight.bold,fontFamily: AppThemeData.medium,);
  static TextStyle  blackMedium15 = TextStyle(color: ColorConst.black,fontSize: 15,
    fontFamily: AppThemeData.medium,fontWeight: FontWeight.bold,);

  static TextStyle  whiteMedium24 = TextStyle(color: ColorConst.white,fontSize: 24,
    fontFamily: AppThemeData.bold,fontWeight: FontWeight.bold,);
  static TextStyle  whiteMedium48 = TextStyle(color: ColorConst.white,fontSize: 48,
    fontFamily: AppThemeData.bold,fontWeight: FontWeight.bold,);
}