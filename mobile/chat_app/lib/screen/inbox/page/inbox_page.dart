// lib/modules/inbox/inbox_page.dart
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/screen/inbox/controller/inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InboxPage extends StatelessWidget {
  final controller = Get.put(InboxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: () => Get.toNamed(AppRoutes.createGroup))],
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.groups.length,
          itemBuilder: (_, i) {
            final group = controller.groups[i];
            return ListTile(
              title: Text(group['name']),
              onTap: () => Get.toNamed(AppRoutes.chat, arguments: group),
            );
          },
        ),
      ),
    );
  }
}
