import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/Authentication/Controller/auth_controller.dart';
import 'package:sms/Authentication/Views/register_user_screen.dart';
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
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                hintText: "Email",
                isShowBorder: true,
                inputAction: TextInputAction.next,
                inputType: TextInputType.text,
                controller: email,
              ),
              SizedBox(
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
              SizedBox(
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
                            await authController.login(email.text, password.text);
                            authController.stopLoading();
                          }
                        },
                      );
              }),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Signup"),
                ),
                onTap: () {
                  Get.toNamed(RegisterUserScreen.routeName);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
