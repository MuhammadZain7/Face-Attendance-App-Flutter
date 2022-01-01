import 'package:get/get.dart';
import 'package:sms/Authentication/Binding/auth_binding.dart';
import 'package:sms/Authentication/Views/login_screen.dart';
import 'package:sms/Authentication/Views/register_user_screen.dart';
import 'package:sms/Dashboard/Classes/classes.dart';
import 'package:sms/Dashboard/Screens/dashboard_screen.dart';
import 'package:sms/Dashboard/Students/add_student.dart';
import 'package:sms/Dashboard/Students/students_screen.dart';
import 'package:sms/Dashboard/dashboard_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: LoginScreen.routeName,
      page: () => LoginScreen(),
      binding: AuthBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: RegisterUserScreen.routeName,
      page: () => RegisterUserScreen(),
      binding: AuthBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: DashboardScreen.routeName,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: ClassScreen.routeName,
      page: () => ClassScreen(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: StudentsScreen.routeName,
      page: () => StudentsScreen(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: AddStudentScreen.routeName,
      page: () => AddStudentScreen(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
  ];
}
