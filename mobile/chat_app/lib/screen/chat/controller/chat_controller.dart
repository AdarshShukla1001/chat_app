// lib/modules/chat/chat_controller.dart
import 'package:chat_app/service/api_service.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:get/get.dart'; 

class ChatController extends GetxController {
  var messages = [].obs;
  var messageText = ''.obs;
  late String groupId;

  @override
  void onInit() {
    super.onInit();
    final group = Get.arguments;
    groupId = group['_id'];
    SocketService.joinGroup(groupId);
    loadMessages();

    SocketService.onNewMessage((data) {
      if (data['groupId'] == groupId) {
        messages.add(data);
      }
    });
  }

  void loadMessages() async {
    final data = await ApiService.getMessages(groupId);
    messages.value = data;
  }

  void sendMessage() {
    if (messageText.value.trim().isEmpty) return;
    SocketService.sendGroupMessage(groupId, messageText.value.trim());
    messageText.value = '';
  }
}
