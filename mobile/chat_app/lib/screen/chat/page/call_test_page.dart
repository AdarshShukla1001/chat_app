import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/screen/call/page/call_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallTestPage extends StatelessWidget {
  final TextEditingController userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Call Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Enter user ID to call:"),
            TextField(
              controller: userIdController,
              decoration: InputDecoration(labelText: "Remote User ID", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userId = userIdController.text.trim();
                if (userId.isNotEmpty) {
                  Get.toNamed(AppRoutes.call, arguments: {'toUserId': userId, 'isCaller': true});
                }
              },
              child: Text("Start Call"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Just go back to main
              },
              child: Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
