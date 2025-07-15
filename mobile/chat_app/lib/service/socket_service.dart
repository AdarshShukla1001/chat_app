import 'package:chat_app/service/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static late IO.Socket socket;

  void connect() {
    final token = ApiService().getToken();
    if (token == null) {
      print('⚠️ No token found. Socket connection aborted.');
      return;
    }

    print('🔐 Connecting socket with token: $token');

    socket = IO.io('http://192.168.1.17:5001', IO.OptionBuilder().setTransports(['websocket']).enableAutoConnect().setAuth({'token': token}).build());

    socket.connect();

    socket.onConnect((_) => print('🔌 Socket connected to server.'));
    socket.onDisconnect((_) => print('❌ Socket disconnected.'));
    socket.onConnectError((data) => print('⚠️ Connect error: $data'));
    socket.onError((data) => print('🚨 Socket error: $data'));
  }

  static void joinGroup(String groupId) {
    print('➡️ Emitting join_group for groupId: $groupId');
    socket.emit('join_group', groupId);
  }

  static void sendGroupMessage(String groupId, String content, {String? parentMessage}) {
    final payload = {'groupId': groupId, 'content': content};
    if (parentMessage != null) payload['parentMessage'] = parentMessage;
    print('➡️ Emitting: $payload');
    socket.emit('send_message', payload);
  }

  static void onNewMessage(Function(dynamic) handler) {
    print('📥 Listening for new_message event');
    socket.on('new_message', (data) {
      print('📨 New message received: $data');
      handler(data);
    });
  }

  static void reactToMessage(String messageId, String emoji) {
    socket.emit('react_to_message', {'messageId': messageId, 'emoji': emoji});
  }

  static void onMessageReacted(Function(dynamic) handler) {
    print('📥 Listening for message_reacted event');
    socket.on('message_reacted', (data) {
      print('❤️ Reaction received: $data');
      handler(data);
    });
  }
}
