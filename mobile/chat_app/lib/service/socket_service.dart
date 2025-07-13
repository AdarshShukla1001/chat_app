// lib/socket_service.dart
import 'package:chat_app/service/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static late IO.Socket socket;

  void connect() {
    final token = ApiService().getToken();
    if (token == null) return;
    socket = IO.io('http://192.168.1.7:5001', IO.OptionBuilder().setTransports(['websocket']).enableAutoConnect().setAuth({'token': token}).build());

    socket.connect();

    socket.onConnect((_) => print('🔌 Socket connected'));
    socket.onDisconnect((_) => print('❌ Socket disconnected'));
  }

  static void joinGroup(String groupId) {
    socket.emit('join_group', groupId);
  }

  static void sendGroupMessage(String groupId, String content) {
    socket.emit('group_message', {'groupId': groupId, 'content': content});
  }

  static void onNewMessage(Function(dynamic message) handler) {
    socket.on('new_message', handler);
  }
}
