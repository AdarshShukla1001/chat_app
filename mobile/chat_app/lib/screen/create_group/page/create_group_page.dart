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
              onChanged: (val) => controller.name.value = val,
            ),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: controller.participants
                    .map(
                      (id) => ListTile(
                        title: Text(id),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.participants.remove(id),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: participantController,
                    decoration: InputDecoration(labelText: "Participant User ID"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final id = participantController.text.trim();
                    if (id.isNotEmpty && !controller.participants.contains(id)) {
                      controller.participants.add(id);
                      participantController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.name.value = nameController.text;
                controller.createGroup();
              },
              child: Text("Create Group"),
            ),
          ],
        ),
      ),
    );
  }
}
