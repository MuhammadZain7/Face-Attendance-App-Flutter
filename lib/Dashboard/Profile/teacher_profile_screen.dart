import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/Dashboard/dashboard_controller.dart';
import 'package:sms/Models/teacher.dart';
import 'package:sms/Utils/color_resources.dart';
import 'package:sms/Utils/constants.dart';
import 'package:sms/Widgets/profile_widget.dart';

class TeacherProfileScreen extends StatelessWidget {
  TeacherProfileScreen({Key? key}) : super(key: key);
  static const String routeName = "/teacher_profile_screen";
  final dashCtrl = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    TeacherModel? teacherModel = getUserFromStorage();
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          ProfileWidget(onClicked: () {

          },),
          SizedBox(
            height: 20,
          ),
          Divider(),
          ListTile(
            onTap: () {},
            title: Text(
              "Name: ${teacherModel?.name}",
              style: TextStyle(
                  fontSize: 18,
                  color: ColorResources.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              Icons.perm_identity_outlined,
              color: ColorResources.primaryColor,
            ),
          ),
          Divider(),
          ListTile(
            onTap: () {},
            title: Text(
              "Email: ${teacherModel?.email}",
              style: TextStyle(
                  fontSize: 18,
                  color: ColorResources.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              Icons.email_outlined,
              color: ColorResources.primaryColor,
            ),
          ),
          Spacer(),
          ListTile(
            onTap: () {
              logoutDialog(context);
            },
            tileColor: Colors.redAccent,
            title: Text(
              "Logout",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w900),
            ),

          ),
        ],
      ),
    );
  }
}
