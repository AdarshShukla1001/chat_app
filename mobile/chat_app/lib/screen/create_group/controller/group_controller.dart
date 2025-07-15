// lib/modules/group/group_controller.dart
import 'dart:convert';

import 'package:chat_app/models/group_model.dart';
import 'package:chat_app/service/api_service.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  var name = ''.obs;
  var participants = <String>[].obs;
  var createdGroup = Rxn<GroupModel>();

  Future<void> createGroup() async {
    if (name.value.trim().isEmpty || participants.length < 2) {
      Get.snackbar("Error", "Group name and at least 2 participants are required");
      return;
    }

    final res = await ApiService.createGroup(name.value.trim(), participants);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final group = GroupModel.fromJson(jsonDecode(res.body));
      createdGroup.value = group;
      Get.back(); // Pop CreateGroupPage
      Get.snackbar("Success", "Group created successfully");
    } else {
      Get.snackbar("Error", "Failed to create group");
    }
  }
}
