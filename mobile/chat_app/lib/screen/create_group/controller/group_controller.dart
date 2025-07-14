// lib/modules/group/group_controller.dart
import 'package:chat_app/service/api_service.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  var name = ''.obs;
  var participants = <String>[].obs;

  void createGroup() async {
    final res = await ApiService.createGroup(name.value, participants);
    if (res.statusCode == 200 || res.statusCode == 201) {
      Get.back();
      Get.snackbar("Success", "Group created");
    } else {
      Get.snackbar("Error", "Group creation failed");
    }
  }
}
