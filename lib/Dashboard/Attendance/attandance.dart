import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms/Dashboard/dashboard_controller.dart';
import 'package:sms/Models/class_model.dart';
import 'package:sms/Models/identify_model.dart';
import 'package:sms/Models/student_model.dart';
import 'package:sms/Utils/constants.dart';

class AttendanceScreen extends StatelessWidget {
  AttendanceScreen({Key? key}) : super(key: key);
  static const String routeName = "/attendance_screen";

  ClassModel classModel = Get.arguments;
  final dashCtrl = Get.find<DashboardController>();
  XFile? image;
  final ImagePicker _picker = ImagePicker();

  // List<Candidate> identifiedStudents = [];
  List<StudentModel> studentList = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
      ),
      body: GetBuilder<DashboardController>(builder: (_) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    if (kIsWeb) {
                      image = await _picker.pickImage(source: ImageSource.gallery);
                    } else {
                      String? selectedType = await pickImageDialog(context);
                      if (selectedType == "Camera") {
                        image =
                            await _picker.pickImage(source: ImageSource.camera);
                      } else if (selectedType == "Gallery") {
                        image = await _picker.pickImage(
                            source: ImageSource.gallery);
                      } else {
                        Fluttertoast.showToast(msg: "Select Image");
                      }
                    }
                    dashCtrl.update();
                  },
                  child: image != null
                      ? Image.file(
                          File(image!.path),
                          height: 200,
                          width: double.infinity,
                        )
                      : Image.asset(
                          "assets/icons/capture.png",
                          height: 200,
                        ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Pick or Capture Image to Take Attendance, one image can take maximum 10 Students.",
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              if (studentList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: studentList.length,
                  itemBuilder: (context, index) {
                    StudentModel categoryModel = studentList.elementAt(index);
                    return GetBuilder<DashboardController>(builder: (context) {
                      return Card(
                          child: ListTile(
                        leading: Image.network(
                            dashCtrl.getStudentImageUrl(categoryModel.photo)),
                        title: Text(categoryModel.name),
                        subtitle: Text(categoryModel.email),
                      ));
                    });
                  },
                ),
              if (studentList.isNotEmpty)
                TextButton(
                    onPressed: () async {
                      await dashCtrl.addAttendance(
                          studentList, classModel.classId);
                      studentList.clear();
                      dashCtrl.update();
                    },
                    child: Text("Mark Attendance"))
            ],
          ),
        );
      }),
      floatingActionButton: GetBuilder<DashboardController>(builder: (_) {
        return isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      if (kIsWeb) {
                        image = await _picker.pickImage(
                            source: ImageSource.gallery);
                      } else {
                        String? selectedType = await pickImageDialog(context);
                        if (selectedType == "Camera") {
                          image = await _picker.pickImage(
                              source: ImageSource.camera);
                        } else if (selectedType == "Gallery") {
                          image = await _picker.pickImage(
                              source: ImageSource.gallery);
                        } else {
                          Fluttertoast.showToast(msg: "Select Image");
                        }
                      }
                      dashCtrl.update();
                    },
                    heroTag: null,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "assets/icons/take_img.png",
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      if (image != null) {
                        isLoading = true;
                        dashCtrl.update();
                        log("classsIDD ${classModel.classId}");
                        List<Candidate> identifiedStudents =
                            await dashCtrl.faceIdentification(
                                classModel.classId, File(image!.path));
                        if (identifiedStudents.isNotEmpty) {
                          studentList = await dashCtrl
                              .getStudentFromIds(identifiedStudents);
                          dashCtrl.update();
                        } else {
                          showSnackBar("No Student Found!");
                        }
                        isLoading = false;
                        dashCtrl.update();
                      } else {
                        Fluttertoast.showToast(msg: "First Select Image");
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "assets/icons/face.png",
                      width: 40,
                      height: 40,
                    ),
                    heroTag: null,
                  ),
                ],
              );
      }),
    );
  }
}
