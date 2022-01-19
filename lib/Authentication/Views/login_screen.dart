import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/Authentication/Controller/auth_controller.dart';
import 'package:sms/Authentication/Views/register_user_screen.dart';
import 'package:sms/Authentication/Views/student_login.dart';
import 'package:sms/Widgets/custom_button.dart';
import 'package:sms/Widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = "/login";
  final _formKey = GlobalKey<FormState>();

  final authController = Get.find<AuthController>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Teacher Login"),
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
                    hintText: "Email",
                    isShowBorder: true,
                    inputAction: TextInputAction.next,
                    inputType: TextInputType.text,
                    controller: email,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    hintText: "Password",
                    isShowBorder: true,
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
                        ? Center(child: CircularProgressIndicator())
                        : CustomButton(
                            btnTxt: "Login",
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                authController.startLoading();
                                await authController.login(
                                    email.text, password.text);
                                authController.stopLoading();
                              }
                            },
                          );
                  }),
                  InkWell(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Signup"),
                    ),
                    onTap: () {
                      Get.toNamed(RegisterUserScreen.routeName);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(StudentLogin.routeName);
                    },
                    child: const Text("Student Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
