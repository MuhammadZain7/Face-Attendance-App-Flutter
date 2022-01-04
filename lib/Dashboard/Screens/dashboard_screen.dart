import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms/Authentication/Views/login_screen.dart';
import 'package:sms/Dashboard/Classes/classes.dart';
import 'package:sms/Dashboard/Profile/teacher_profile_screen.dart';
import 'package:sms/Utils/constants.dart';
import 'package:sms/Utils/dimensions.dart';

import '../dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  static const String routeName = "/dashboard";
  final dashController = Get.find<DashboardController>();

  DashboardScreen({Key? key}) : super(key: key);

  int _selectedIndex = 0;
  static TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    ClassScreen(),
    TeacherProfileScreen(),
    // Text(
    //   'Index 2: School',
    //   style: optionStyle,
    // ),
  ];

  void _onItemTapped(int index) {
    _selectedIndex = index;
    dashController.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance System'),

      ),
      body: GetBuilder<DashboardController>(builder: (context) {
        return Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        );
      }),
      bottomNavigationBar: GetBuilder<DashboardController>(builder: (context) {
        return BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity),
              label: 'Profile',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.school),
            //   label: 'School',
            // ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        );
      }),
    );
  }
}
