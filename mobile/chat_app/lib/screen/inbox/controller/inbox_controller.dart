// lib/modules/inbox/inbox_controller.dart
import 'package:chat_app/service/api_service.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:get/get.dart';

class InboxController extends GetxController {
  var groups = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    SocketService.onNewMessage((data) => fetchGroups());
  }

  void fetchGroups() async {
    groups.value = await ApiService.getGroups();
  }
}
