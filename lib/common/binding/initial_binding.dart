import 'package:get/get.dart';
import '../../presentation/auth/binding/auth_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
  }
}
