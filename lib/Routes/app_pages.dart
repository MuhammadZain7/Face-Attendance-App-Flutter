import 'package:get/get.dart';
import 'package:sms/Authentication/Binding/auth_binding.dart';
import 'package:sms/Authentication/Controller/auth_controller.dart';
import 'package:sms/Authentication/Views/login_screen.dart';
import 'package:sms/Authentication/Views/profile_status.dart';
import 'package:sms/Authentication/Views/register_user_screen.dart';
import 'package:sms/Authentication/Views/student_login.dart';
import 'package:sms/Dashboard/Attendance/attandance.dart';
import 'package:sms/Dashboard/Attendance/view_attendance_by_std.dart';
import 'package:sms/Dashboard/Classes/classes.dart';
import 'package:sms/Dashboard/Profile/teacher_profile_screen.dart';
import 'package:sms/Dashboard/Screens/dashboard_screen.dart';
import 'package:sms/Dashboard/StudentScreens/view_student_classes.dart';
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
    GetPage(
      name: AttendanceScreen.routeName,
      page: () => AttendanceScreen(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: ViewAttendanceByStd.routeName,
      page: () => ViewAttendanceByStd(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: TeacherProfileScreen.routeName,
      page: () => TeacherProfileScreen(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: ProfileStatus.routeName,
      page: () => const ProfileStatus(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: StudentLogin.routeName,
      page: () => StudentLogin(),
      binding: AuthBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: ViewStudentClasses.routeName,
      page: () => ViewStudentClasses(),
      binding: DashboardBinding(),
      preventDuplicates: true,
    ),
  ];
}
