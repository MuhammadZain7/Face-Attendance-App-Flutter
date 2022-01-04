import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String? imagePath;
  final bool isEdit;
  final VoidCallback? onClicked;
  final double size;

  const ProfileWidget({
    Key? key,
    this.imagePath,
    this.size=120,
    this.isEdit = false,
      this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          // Positioned(
          //   bottom: 0,
          //   right: 4,
          //   child: buildEditIcon(color),
          // ),
        ],
      ),
    );
  }

  Widget buildImage() {
    return ClipOval(
      child: imagePath != null && imagePath!.isNotEmpty
          ? imagePath!.toString().contains("com.ziyaan.sms")
              ? kIsWeb
                  ? Material(
                      color: Colors.transparent,
                      child: Ink.image(
                        image: NetworkImage(imagePath ?? ""),
                        fit: BoxFit.cover,
                        width: size,
                        height: size,
                        child: InkWell(onTap: onClicked),
                      ),
                    )
                  : Material(
                      color: Colors.transparent,
                      child: Ink.image(
                        image: Image.file(File(imagePath ?? "")).image,
                        fit: BoxFit.cover,
                        width: size,
                        height: size,
                        child: InkWell(onTap: onClicked),
                      ),
                    )
              : Material(
                  color: Colors.transparent,
                  child: Ink.image(
                    image: NetworkImage(imagePath ?? ""),
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    child: InkWell(onTap: onClicked),
                  ),
                )
          : Material(
              color: Colors.transparent,
              child: Ink.image(
                image: const AssetImage("assets/images/client_dp.png"),
                fit: BoxFit.cover,
                width: size,
                height: size,
                child: InkWell(onTap: onClicked),
              ),
            ),
    );
  }

  // Widget buildEditIcon(Color color) => buildCircle(
  //       color: Colors.white,
  //       all: 3,
  //       child: buildCircle(
  //         color: color,
  //         all: 8,
  //         child: Icon(
  //           isEdit ? Icons.add_a_photo : Icons.edit,
  //           color: Colors.white,
  //           size: 20,
  //         ),
  //       ),
  //     );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
