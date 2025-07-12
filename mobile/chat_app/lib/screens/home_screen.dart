import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/service/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List groups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final data = await ApiService.getGroups();
    setState(() => groups = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return ListTile(
            title: Text(group['name'] ?? '1-1 Chat'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen())),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), onPressed: () async {}),
    );
  }
}
