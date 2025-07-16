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

  // --------------------- WebRTC Calls ---------------------

  static void sendCallOffer(String toUserId, Map<String, dynamic> offer) {
    socket.emit('call:offer', {'toUserId': toUserId, 'offer': offer});
  }

  static void sendCallAnswer(String toUserId, Map<String, dynamic> answer) {
    socket.emit('call:answer', {'toUserId': toUserId, 'answer': answer});
  }

  static void sendIceCandidate(String toUserId, Map<String, dynamic> candidate) {
    socket.emit('call:ice-candidate', {'toUserId': toUserId, 'candidate': candidate});
  }

  static void sendCallEnd(String toUserId) {
    socket.emit('call:end', {'toUserId': toUserId});
  }

  static void onCallOffer(Function(String fromUserId, Map<String, dynamic> offer) handler) {
    socket.on('call:offer', (data) => handler(data['fromUserId'], data['offer']));
  }

  static void onCallAnswer(Function(Map<String, dynamic> answer) handler) {
    socket.on('call:answer', (data) => handler(data['answer']));
  }

  static void onIceCandidate(Function(Map<String, dynamic> candidate) handler) {
    socket.on('call:ice-candidate', (data) => handler(data['candidate']));
  }

  static void onCallEnd(Function(String fromUserId) handler) {
    socket.on('call:end', (data) => handler(data['fromUserId']));
  }
}
