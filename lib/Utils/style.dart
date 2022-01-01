import 'package:flutter/material.dart';

import 'color_resources.dart';
import 'dimensions.dart';

class CustomStyle{
  static var textStyle = TextStyle(
      color: ColorResources.COLOR_GREY, fontSize: Dimensions.TEXT_SIZE_DEFAULT
  );
  static var focusBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(Dimensions.OUTLINE_BORDER)),
    borderSide: BorderSide(color: ColorResources.COLOR_GREY.withOpacity(0.3), width: 2.0),
  );
  static var enableBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(Dimensions.OUTLINE_BORDER)),
    borderSide: BorderSide(color: ColorResources.COLOR_GREY.withOpacity(0.3), width: 1.0),
  );
}