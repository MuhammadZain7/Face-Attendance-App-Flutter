import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
