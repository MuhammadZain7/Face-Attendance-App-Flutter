import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/Authentication/Views/login_screen.dart';
import 'package:sms/Dashboard/Attendance/view_attendance_by_std.dart';
import 'package:sms/Dashboard/Students/students_screen.dart';
import 'package:sms/Models/student_model.dart';
import 'package:sms/Utils/constants.dart';

import '../dashboard_controller.dart';

class ViewStudentClasses extends StatelessWidget {
  ViewStudentClasses({Key? key}) : super(key: key);
  static const String routeName = "/view_student_classes";

  bool isSubmitLoading = false;
  final dashCtrl = Get.find<DashboardController>();
  StudentModel studentModel = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${studentModel.name} Classes"),
        actions: [
          IconButton(
              onPressed: () {
                logOutStudent();
                Get.offAllNamed(LoginScreen.routeName);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dashCtrl.getStudentByEmail(studentModel),
        builder: (context, snapshot) {
          if (snapshot.data != null &&
              snapshot.hasData &&
              snapshot.data!.docs.isNotEmpty) {
            List categories = snapshot.data!.docs;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                StudentModel categoryModel =
                    StudentModel.fromJson(categories.toList()[index].data());
                print('${snapshot.data!.docs.elementAt(index).id}');

                return Card(
                    child: GetBuilder<DashboardController>(builder: (_) {
                  return ListTile(
                    onTap: () {
                      Get.toNamed(ViewAttendanceByStd.routeName,
                          arguments: studentModel);
                    },
                    title: Text(categoryModel.className),
                    subtitle: Text(categoryModel.classCode),
                  );
                }));
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("No Class Available"));
          }
        },
      ),
    );
  }
}
