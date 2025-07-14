// lib/modules/auth/auth_controller.dart
import 'package:chat_app/service/api_service.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  var isLoading = false.obs;

  void login() async {
    isLoading.value = true;
    final res = await ApiService.login(emailController.text, passwordController.text);
    isLoading.value = false;

    if (res.statusCode == 200) {
      SocketService().connect();
      Get.offAllNamed(AppRoutes.inbox);
    } else {
      Get.snackbar("Error", "Login failed");
    }
  }

  void register() async {
    isLoading.value = true;
    final res = await ApiService.register(nameController.text, emailController.text, passwordController.text);
    isLoading.value = false;

    if (res.statusCode == 200 || res.statusCode == 201) {
      Get.snackbar("Success", "Account created. Login now.");
      Get.offNamed(AppRoutes.login);
    } else {
      Get.snackbar("Error", "Registration failed");
    }
  }
}
