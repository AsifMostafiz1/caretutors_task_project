import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import '../repository/dashboard_repository.dart';
import '../repository/dashboard_repository_impl.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardRepository>(() => DashboardRepositoryImpl());
    Get.lazyPut<DashboardController>(
      () => DashboardController(repository: Get.find<DashboardRepository>()),
    );
  }
}
