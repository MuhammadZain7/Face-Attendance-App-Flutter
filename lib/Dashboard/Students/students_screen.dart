import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sms/Dashboard/Attendance/attandance.dart';
import 'package:sms/Dashboard/Students/add_student.dart';
import 'package:sms/Dashboard/dashboard_controller.dart';
import 'package:sms/Models/attendance_model.dart';
import 'package:sms/Models/class_model.dart';
import 'package:sms/Models/student_model.dart';
import 'package:sms/Utils/constants.dart';
import 'package:sms/Widgets/custom_button.dart';
import 'package:sms/Widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class StudentsScreen extends StatelessWidget {
  static const String routeName = "/student_screen";

  bool isSubmitLoading = false;

  bool isDeleting = false;

  StudentsScreen({Key? key}) : super(key: key);
  final dashCtrl = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  final classId = Get.arguments;
  int? studentLength;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Class Name"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person_outline), text: "Students"),
              Tab(icon: Icon(Icons.camera_alt), text: "Attendance")
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: dashCtrl.getStudentsByClassId(classId),
              builder: (context, snapshot) {
                if (snapshot.data != null &&
                    snapshot.hasData &&
                    snapshot.data!.docs.isNotEmpty) {
                  List categories = snapshot.data!.docs;
                  studentLength = categories.length;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      StudentModel categoryModel = StudentModel.fromJson(
                          categories.toList()[index].data());
                      return GetBuilder<DashboardController>(
                          builder: (context) {
                        return Card(
                            child: ListTile(
                          leading: Image.network(
                              dashCtrl.getStudentImageUrl(categoryModel.photo)),
                          title: Text(categoryModel.name),
                          subtitle: Text(categoryModel.email),
                          trailing: isDeleting
                              ? CircularProgressIndicator()
                              : IconButton(
                                  onPressed: () async {
                                    isDeleting = true;
                                    dashCtrl.update();
                                    await dashCtrl.deleteStudentFromClass(
                                        categoryModel.classId,
                                        categoryModel.stdId,
                                        snapshot.data!.docs
                                            .elementAt(index)
                                            .id);
                                    isDeleting = false;
                                    dashCtrl.update();
                                    Fluttertoast.showToast(
                                        msg: "Deleted Successfully");
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                ),
                        ));
                      });
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text("No Students Available"));
                }
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: dashCtrl.getAttendance(classId),
              builder: (context, snapshot) {
                if (snapshot.data != null &&
                    snapshot.hasData &&
                    snapshot.data!.docs.isNotEmpty) {
                  List categories = snapshot.data!.docs;
                  studentLength = categories.length;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      AttendanceModel categoryModel = AttendanceModel.fromJson(
                          categories.toList()[index].data());
                      return GetBuilder<DashboardController>(
                          builder: (context) {
                        var date = DateFormat('yyyy-MM-dd – kk:mm:a').format(
                            DateTime.fromMicrosecondsSinceEpoch(
                                int.parse(categoryModel.atdDate)));

                        return Card(
                            child: ListTile(
                          leading: Image.network(dashCtrl
                              .getStudentImageUrl(categoryModel.stdPhoto)),
                          title: Text(categoryModel.stdName),
                          subtitle: Text("${categoryModel.stdEmail}\n${date}"),
                          trailing: Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          // trailing: isDeleting
                          //     ? CircularProgressIndicator()
                          //     : IconButton(
                          //         onPressed: () async {
                          //           isDeleting = true;
                          //           dashCtrl.update();
                          //           await dashCtrl.deleteStudentFromClass(
                          //               categoryModel.classId,
                          //               categoryModel.stdId,
                          //               snapshot.data!.docs
                          //                   .elementAt(index)
                          //                   .id);
                          //           isDeleting = false;
                          //           dashCtrl.update();
                          //           Fluttertoast.showToast(
                          //               msg: "Deleted Successfully");
                          //         },
                          //         icon: Icon(
                          //           Icons.delete,
                          //           color: Colors.redAccent,
                          //         ),
                          //       ),
                        ));
                      });
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text("No Students Available"));
                }
              },
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (studentLength != null && studentLength! > 0) {
                  Get.toNamed(AttendanceScreen.routeName, arguments: classId);
                }
              },
              child: Icon(Icons.atm),
              heroTag: null,
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton(
              onPressed: () {
                Get.toNamed(AddStudentScreen.routeName, arguments: classId);
              },
              child: Icon(Icons.add),
              heroTag: null,
            ),
          ],
        ),
      ),
    );
  }
}
