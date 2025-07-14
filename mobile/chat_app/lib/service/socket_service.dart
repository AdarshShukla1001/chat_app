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
    final payload = {'groupId': groupId, 'content': content, if (parentMessage != null) 'parentMessage': parentMessage};
    print('➡️ Sending group message: $payload');
    socket.emit('group_message', payload);
  }

  static void sendOneToOneMessage(String toUserId, String content, {String? parentMessage}) {
    final payload = {'toUserId': toUserId, 'content': content, if (parentMessage != null) 'parentMessage': parentMessage};
    print('➡️ Sending one-to-one message: $payload');
    socket.emit('one_to_one_message', payload);
  }

  static void reactToMessage(String messageId, String emoji) {
    final payload = {'messageId': messageId, 'emoji': emoji};
    print('❤️ Reacting to message: $payload');
    socket.emit('react_to_message', payload);
  }

  static void onNewMessage(Function(dynamic) handler) {
    print('📥 Listening for new_message event');
    socket.on('new_message', (data) {
      print('📨 New message received: $data');
      handler(data);
    });
  }

  static void onMessageReacted(Function(dynamic) handler) {
    print('📥 Listening for message_reacted event');
    socket.on('message_reacted', (data) {
      print('💬 Message reacted: $data');
      handler(data);
    });
  }
}
