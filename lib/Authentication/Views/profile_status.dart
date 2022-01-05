import 'package:flutter/material.dart';
import 'package:sms/Models/teacher.dart';
import 'package:sms/Utils/color_resources.dart';
import 'package:sms/Utils/constants.dart';

class ProfileStatus extends StatefulWidget {
  static const String routeName = "/profile_status";

  const ProfileStatus({Key? key}) : super(key: key);

  @override
  State<ProfileStatus> createState() => _ProfileStatusState();
}

class _ProfileStatusState extends State<ProfileStatus> {
  TeacherModel? _teacherModel;

  @override
  void initState() {
    _teacherModel = getUserFromStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Status"),
        actions: [
          IconButton(
            onPressed: () {
              logoutDialog(context);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Image.asset("assets/images/contact_admin.jpg"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Dear ${_teacherModel!.name}!",
                  style: const TextStyle(
                      fontSize: 30, color: ColorResources.primaryColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Your Account is Not Activated, To Activate your account kindly contact over admin",
                  style: TextStyle(
                      fontSize: 15, color: ColorResources.primaryColor),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
