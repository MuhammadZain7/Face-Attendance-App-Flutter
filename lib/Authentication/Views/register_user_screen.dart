import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/Authentication/Controller/auth_controller.dart';
import 'package:sms/Widgets/custom_button.dart';
import 'package:sms/Widgets/custom_text_field.dart';

class RegisterUserScreen extends StatelessWidget {
  static const String routeName = "/register_user";
  final authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();

  TextEditingController email = TextEditingController();

  TextEditingController phone = TextEditingController();

  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Teacher"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: "Name",
                  isShowBorder: true,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.text,
                  controller: name,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: "Email",
                  isShowBorder: true,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.emailAddress,
                  controller: email,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: "Phone",
                  isShowBorder: true,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.phone,
                  controller: phone,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: "Password",
                  isShowBorder: true,
                  inputAction: TextInputAction.next,
                  inputType: TextInputType.text,
                  isPassword: true,
                  controller: password,
                ),
                SizedBox(
                  height: 20,
                ),
                GetBuilder<AuthController>(builder: (context) {
                  return authController.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : CustomButton(
                          btnTxt: "Register User",
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              authController.startLoading();

                              await authController.registerUser(name.text,
                                  email.text, phone.text, password.text);

                              authController.stopLoading();
                            }
                          },
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
