import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sms/Dashboard/dashboard_controller.dart';
import 'package:sms/Models/class_model.dart';
import 'package:sms/Utils/constants.dart';
import 'package:sms/Widgets/custom_button.dart';
import 'package:sms/Widgets/custom_text_field.dart';
import 'package:sms/Widgets/profile_widget.dart';

class AddStudentScreen extends StatelessWidget {
  static const String routeName = "/add_student_screen";

  bool isSubmitLoading = false;

  AddStudentScreen({Key? key}) : super(key: key);
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  XFile? image;
  final ImagePicker _picker = ImagePicker();
  final dashCtrl = Get.find<DashboardController>();

  ClassModel classModel = Get.arguments;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController rollNo = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Student"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                GetBuilder<DashboardController>(builder: (_) {
                  return ProfileWidget(
                    imagePath: image?.path ?? "",
                    onClicked: () async {
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
                  );
                }),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: "Name",
                  isShowBorder: true,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.text,
                  controller: name,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText: "Email",
                  isShowBorder: true,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.emailAddress,
                  controller: email,
                  isEmail: true,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText: "Phone",
                  isShowBorder: true,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.phone,
                  controller: phone,
                ),
                SizedBox(
                  height: 8,
                ),
                CustomTextField(
                  hintText: "Roll Number",
                  isShowBorder: true,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.text,
                  controller: rollNo,
                ),
                SizedBox(
                  height: 20,
                ),
                GetBuilder<DashboardController>(builder: (_) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: isSubmitLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            btnTxt: "Add Student",
                            onTap: () async {
                              if (_formKey.currentState!.validate() &&
                                  image != null) {
                                isSubmitLoading = true;
                                dashCtrl.update();

                                await dashCtrl.addStudentInClass(
                                    classModel.classId,
                                    classModel.className,
                                    classModel.classCode,
                                    name.text,
                                    email.text,
                                    phone.text,
                                    rollNo.text,
                                    File(image!.path));

                                // await dashCtrl
                                //     .detectFacesFromImage(File(image!.path));

                                isSubmitLoading = false;

                                dashCtrl.update();
                                Get.back();
                              }
                            },
                          ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploadFile(String filePath, String id) async {
    try {
      if (kIsWeb) {
        await storage.ref("StudentsImages/$id").putData(
            await image!.readAsBytes(),
            SettableMetadata(contentType: "image/png"));
      } else {
        await storage.ref("StudentsImages/$id").putFile(File(filePath));
      }
    } on firebase_storage.FirebaseException catch (e) {
      log(e.message ?? "");
    }
  }
}
