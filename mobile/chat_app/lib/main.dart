// lib/main.dart
import 'package:chat_app/screen/auth/page/login_page.dart';
import 'package:chat_app/screen/auth/page/registration_page.dart';
import 'package:chat_app/screen/chat/page/chat_page.dart';
import 'package:chat_app/screen/create_group/page/create_group_page.dart';
import 'package:chat_app/screen/inbox/page/inbox_page.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'service/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init(); // Load token if available

  final isLoggedIn = await ApiService.isLoggedIn();

  if (isLoggedIn) {
    SocketService().connect();
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      initialRoute: isLoggedIn ? AppRoutes.inbox : AppRoutes.login,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => LoginPage()),
        GetPage(name: AppRoutes.register, page: () => RegisterPage()),
        GetPage(name: AppRoutes.inbox, page: () => InboxPage()),
        GetPage(name: AppRoutes.createGroup, page: () => CreateGroupPage()),
        GetPage(name: AppRoutes.chat, page: () => ChatPage()),
      ],
    );
  }
}
