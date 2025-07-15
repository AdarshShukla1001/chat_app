import 'package:chat_app/service/api_service.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  List messages = [];
  String userId = ''; // Replace with real user ID from login

  @override
  void initState() {
    super.initState();
    fetchMessages();
    initSocket();
  }

  void initSocket() {
    SocketService.joinGroup('68728d912a2b50299ac027c2');
    SocketService.onNewMessage((data) {
      setState(() => messages.add(data));
    });
  }

  Future<void> fetchMessages() async {
    final data = await ApiService.getMessages('68728d912a2b50299ac027c2');
    setState(() => messages = data);
  }

  void sendMessage() {
    final content = messageController.text;
    if (content.isEmpty) return;

    SocketService.sendGroupMessage('68728d912a2b50299ac027c2', content);
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(title: Text(messages[index]['content']), subtitle: Text(messages[index]['sender']['email'] ?? '')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
