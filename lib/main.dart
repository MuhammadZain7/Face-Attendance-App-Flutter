import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sms/Authentication/Views/login_screen.dart';

import 'Authentication/Binding/auth_binding.dart';
import 'Routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Attendance System",
      debugShowCheckedModeBanner: false,
      onInit: () {
        Get.put(AuthBinding());

        // Get.put(ChatService());
        // Get.put(ChatController());
      },
      initialBinding: AuthBinding(),
      initialRoute: LoginScreen.routeName,
      getPages: AppPages.routes,
    );
  }
}
