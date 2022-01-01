import 'package:get/get.dart';
import 'package:sms/Authentication/Controller/auth_controller.dart';
import 'package:sms/Authentication/auth_services.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<AuthBinding>(
    //   () => AuthBinding(),
    // );

    Get.put(AuthService());
    Get.put(AuthController());
  }
}
