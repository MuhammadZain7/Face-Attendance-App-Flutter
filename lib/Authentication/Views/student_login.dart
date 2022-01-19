import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sms/Authentication/Controller/auth_controller.dart';
import 'package:sms/Authentication/Views/login_screen.dart';
import 'package:sms/Dashboard/Attendance/view_attendance_by_std.dart';
import 'package:sms/Dashboard/StudentScreens/view_student_classes.dart';
import 'package:sms/Models/student_model.dart';
import 'package:sms/Widgets/custom_button.dart';
import 'package:sms/Widgets/custom_text_field.dart';

class StudentLogin extends StatelessWidget {
  static const String routeName = "/student_login";
  final _formKey = GlobalKey<FormState>();

  final authController = Get.find<AuthController>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Student Login"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Image.asset(
                    "assets/images/login_img.jpg",
                    height: 200,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    hintText: "Name",
                    isShowBorder: true,
                    inputAction: TextInputAction.next,
                    inputType: TextInputType.text,
                    controller: email,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    hintText: "Roll No",
                    isShowBorder: true,
                    required: false,
                    inputAction: TextInputAction.next,
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    controller: password,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GetBuilder<AuthController>(builder: (_) {
                    return authController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            btnTxt: "Login",
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                authController.startLoading();
                                StudentModel? student = await authController
                                    .getStudent(email.text, password.text);
                                authController.stopLoading();
                                if (student != null) {
                                  authController.setStudent(student);
                                  Get.offAllNamed(ViewStudentClasses.routeName,
                                      arguments: student);
                                  Fluttertoast.showToast(
                                      msg: "Login Successfully");
                                }
                              }
                            },
                          );
                  }),
                  ElevatedButton(
                      onPressed: () {
                        Get.toNamed(LoginScreen.routeName);
                      },
                      child: const Text("Teacher Login"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
