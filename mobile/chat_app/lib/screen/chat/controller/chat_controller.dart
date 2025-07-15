// lib/modules/chat/chat_controller.dart
import 'dart:convert';

import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/service/api_service.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final messages = <MessageModel>[].obs;
  final messageText = ''.obs;
  late String groupId;

  @override
  void onInit() {
    super.onInit();
    final group = Get.arguments;
    groupId = group['_id'];

    SocketService.joinGroup(groupId);
    loadMessages();

    _setupSocketListeners(); // 👈 added this
  }

  Future<void> loadMessages() async {
    final data = await ApiService.getMessages(groupId);
    messages.assignAll(data);
  }

  void sendMessage() {
    final text = messageText.value.trim();
    if (text.isEmpty) return;

    print('📤 Sending message: $text to group: $groupId');
    SocketService.sendGroupMessage(groupId, text);
    messageText.value = '';
  }

  void _setupSocketListeners() {
    SocketService.onNewMessage((rawData) {
      print('📥 Received new_message from socket: $rawData');

      dynamic data;

      try {
        if (rawData is String) {
          data = jsonDecode(rawData);
        } else {
          data = rawData;
        }

        final incomingGroupId = data['group'] ?? data['groupId'];
        if (incomingGroupId == groupId) {
          final newMessage = MessageModel.fromJson(data);
          messages.add(newMessage);
        } else {
          print('⚠️ Message is for a different group. Ignored.');
        }
      } catch (e) {
        print('❌ Error parsing socket data: $e');
      }
    });

    SocketService.onMessageReacted((data) {
      try {
        final updated = MessageModel.fromJson(data['updatedMessage']);
        final index = messages.indexWhere((m) => m.id == updated.id);
        if (index != -1) {
          messages[index] = updated;
          messages.refresh(); // trigger UI update
        }
      } catch (e) {
        print('❌ Error parsing reaction socket data: $e');
      }
    });
  }
}
