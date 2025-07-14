// lib/modules/group/create_group_page.dart
import 'package:chat_app/screen/create_group/controller/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateGroupPage extends StatelessWidget {
  final controller = Get.put(GroupController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController participantController = TextEditingController();

  CreateGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Group")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Group Name"),
            ),
            Obx(() => Column(children: controller.participants.map((e) => ListTile(title: Text(e))).toList())),
            TextField(
              controller: participantController,
              decoration: InputDecoration(labelText: "Add participant ID"),
            ),
            ElevatedButton(
              onPressed: () {
                controller.name.value = nameController.text;
                controller.participants.add(participantController.text);
                participantController.clear();
              },
              child: Text("Add Participant"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: controller.createGroup, child: Text("Create Group")),
          ],
        ),
      ),
    );
  }
}
