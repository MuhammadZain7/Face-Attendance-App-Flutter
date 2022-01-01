
import 'package:get/get.dart';

import 'dashboard_controller.dart';
import 'dashboard_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardService());
    Get.put(DashboardController());
  }
}
