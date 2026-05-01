import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo_project/routes/app_router.dart';
import '../../../utils/app_constant.dart';
import '../model/user_model.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../utils/app_enums.dart';
import '../repository/auth_repository.dart';
import '../../dashboard/controller/dashboard_controller.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepository repository;

  AuthController({required this.repository});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  bool _isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  Future<void> signUp() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
          type: SnackbarType.error, message: 'Please fill all fields');
      return;
    }

    if (!_isValidEmail(email)) {
      CustomSnackbar.show(
          type: SnackbarType.error, message: 'Please enter a valid email address');
      return;
    }

    try {
      isLoading = true;
      update();

      bool exists = await repository.checkUserExists(email);
      if (exists) {
        isLoading = false;
        update();
        CustomSnackbar.show(
            type: SnackbarType.error,
            message: 'User with this email address already exists');
        return;
      }

      UserModel newUser = UserModel(
        name: name,
        email: email,
        password: password,
      );

      await repository.signUp(newUser);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstant.keyIsLoggedIn, true);
      await prefs.setString(AppConstant.keyUserEmail, email);
      await prefs.setString(AppConstant.keyUserName, name);

      isLoading = false;
      update();
      CustomSnackbar.show(
          type: SnackbarType.success, message: 'Account created successfully');

      AppRouter.router.go(AppRoutes.dashboard);
    } catch (e) {
      isLoading = false;
      update();
      CustomSnackbar.show(
          type: SnackbarType.error, message: 'Failed to create account.');
    }
  }

  Future<void> signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
          type: SnackbarType.error, message: 'Please fill all fields');
      return;
    }

    if (!_isValidEmail(email)) {
      CustomSnackbar.show(
          type: SnackbarType.error, message: 'Please enter a valid email address');
      return;
    }

    try {
      isLoading = true;
      update();

      UserModel? user = await repository.signIn(email);

      if (user != null) {
        if (user.password == password) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool(AppConstant.keyIsLoggedIn, true);
          await prefs.setString(AppConstant.keyUserEmail, user.email);
          await prefs.setString(AppConstant.keyUserName, user.name);

          isLoading = false;
          update();
          CustomSnackbar.show(
              type: SnackbarType.success, message: 'Login successful');
          AppRouter.router.go(AppRoutes.dashboard);
        } else {
          isLoading = false;
          update();
          CustomSnackbar.show(
              type: SnackbarType.error, message: 'Incorrect password');
        }
      } else {
        isLoading = false;
        update();
        CustomSnackbar.show(
            type: SnackbarType.error, message: 'User not found');
      }
    } catch (e) {
      isLoading = false;
      update();
      CustomSnackbar.show(
          type: SnackbarType.error, message: 'Failed to sign in.');
    }
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    isLoading = false;
    isPasswordVisible = false;

    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>(force: true);
    }

    AppRouter.router.go(AppRoutes.signIn);
  }
}
