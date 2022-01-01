
import 'package:flutter/material.dart';
import 'package:sms/Utils/color_resources.dart';

class CustomButton extends StatelessWidget {
  final Function? onTap;
  final String? btnTxt;
  final Color? backgroundColor;

  CustomButton({this.onTap, required this.btnTxt, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onTap == null
          ? ColorResources.COLOR_GREY
          : backgroundColor == null
              ? Theme.of(context).primaryColor
              : backgroundColor,
      // minimumSize: Size(MediaQuery.of(context).size.width, 50),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return ElevatedButton(
      onPressed: onTap as void Function()?,
      style: flatButtonStyle,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(btnTxt ?? "",
            style: Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(color: ColorResources.COLOR_WHITE, fontSize: 14)),
      ),
    );
  }
}
