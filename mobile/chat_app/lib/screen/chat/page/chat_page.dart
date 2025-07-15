// lib/modules/chat/chat_page.dart
import 'package:chat_app/screen/chat/controller/chat_controller.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
 
class ChatPage extends StatelessWidget {
  final controller = Get.put(ChatController());
  final TextEditingController textController = TextEditingController();

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Group Chat")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final msg = messages[messages.length - index - 1];

                  // 🧮 Group reactions by emoji
                  final emojiCounts = <String, int>{};
                  msg.reactions?.values.expand((list) => list).forEach((emoji) {
                    emojiCounts[emoji] = (emojiCounts[emoji] ?? 0) + 1;
                  });

                  return ListTile(
                    title: Text(msg.sender.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.content),
                        const SizedBox(height: 4),
                        if (emojiCounts.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: emojiCounts.entries.map((e) => Chip(label: Text('${e.key} ${e.value}'), backgroundColor: Colors.grey[200])).toList(),
                          ),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(msg.createdAt.toLocal().toIso8601String().substring(11, 16)),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onSelected: (emoji) {
                            SocketService.reactToMessage(msg.id, emoji);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: '❤️', child: Text('❤️')),
                            PopupMenuItem(value: '😂', child: Text('😂')),
                            PopupMenuItem(value: '😮', child: Text('😮')),
                            PopupMenuItem(value: '👍', child: Text('👍')),
                            PopupMenuItem(value: '🔥', child: Text('🔥')),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    onChanged: (value) => controller.messageText.value = value,
                    decoration: const InputDecoration(hintText: "Type a message...", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    controller.sendMessage();
                    textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
