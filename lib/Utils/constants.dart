import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sms/Authentication/Views/login_screen.dart';
import 'package:sms/Models/teacher.dart';

import 'color_resources.dart';

const String baseURL = "https://cll.softologics.com/API/";

String toFormate(DateTime now) {
  return "${now.day.toString().padLeft(2, '0')} ${getMonthName(now.month)} ${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString()}:${now.hour < 12 ? "PM" : "AM"}";
}

int calculateDifference(DateTime date) {
  DateTime now = DateTime.now();
  return DateTime(date.year, date.month, date.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
}

// getFeedbacckMapping()["1"]
Map getFeedbackMapping() {
  return {
    '1': 'Schedule Visit',
    '2': 'Follow Up',
    '3': 'Callback',
    '4': 'Not Interested',
    "5": "Other",
    "6": "Sales Done"
  };
}

void logOut() {
  FirebaseAuth.instance.signOut();
  GetStorage().remove("api_key");
  GetStorage().remove("user");
  GetStorage().erase();
}

void logOutStudent() {
  GetStorage().remove("student");
  GetStorage().erase();
}

Map getOpenFeedbackMapping() {
  return {'1': 'Schedule Visit', '2': 'Follow Up', '3': 'Assigned a Callback'};
}

Map getClosedFeedbackMapping() {
  return {'4': 'Not Interested', "5": "Other", "6": "Sale Done"};
}

Future<String?> pickImageDialog(BuildContext context) async {
  String? selected;
  await showDialog<String>(
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Image'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                selected = "Camera";
                Navigator.pop(context);
              },
              child: const Text('From Camera'),
            ),
            SimpleDialogOption(
              onPressed: () {
                selected = "Gallery";
                Navigator.pop(context);
              },
              child: const Text('From Gallery'),
            ),
          ],
        );
      },
      context: context);
  return selected;
}

Future logoutDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout!"),
          content: const Text("Are you sure want to Logout?"),
          actions: <Widget>[
            FlatButton(
              color: ColorResources.primaryColor,
              textColor: Colors.white,
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              textColor: ColorResources.primaryColor,
              child: const Text('Yes'),
              onPressed: () async {
                logOut();
                Get.offAllNamed(LoginScreen.routeName);
              },
            ),
          ],
        );
      });
}

TeacherModel? getUserFromStorage() {
  if (GetStorage().read("user") != null) {
    return TeacherModel.fromJson(GetStorage().read("user"));
  }
}

String getMonthName(int i) {
  List months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[i - 1];
}

String getErrors(Map input) {
  // List<dynamic> newList = input.values.toList();
  List<String> newList = List<String>.from(input.values.toList());
  return newList.join("\n");
}

showSnackBar(text) {
  final snackBar = SnackBar(content: Text(text));
  if (Get.context != null) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }
}
