import 'package:get/get.dart';
import 'package:chat_app/service/socket_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class CallController extends GetxController {
  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  final RxBool inCall = false.obs;
  final RxString remoteUserId = ''.obs;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  @override
  void onInit() {
    super.onInit();
    _initRenderers();
    _registerSocketListeners();
  }

  void _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> makeCall(String toUserId) async {
    remoteUserId.value = toUserId;
    await _createPeerConnection();

    final offer = await _peerConnection?.createOffer();
    await _peerConnection?.setLocalDescription(offer!);
    SocketService.sendCallOffer(toUserId, offer?.toMap());
  }

  Future<void> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(config);
    localStream = await rtc.navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
    localRenderer.srcObject = localStream;

    localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, localStream!);
    });

    _peerConnection?.onTrack = (event) {
      if (event.track.kind == 'video') {
        remoteStream = event.streams.first;
        remoteRenderer.srcObject = remoteStream;
      }
    };

    _peerConnection?.onIceCandidate = (candidate) {
      SocketService.sendIceCandidate(remoteUserId.value, candidate.toMap());
    };

    inCall.value = true;
  }

  void _registerSocketListeners() {
    SocketService.onCallOffer((fromUserId, offer) async {
      remoteUserId.value = fromUserId;
      await _createPeerConnection();
      await _peerConnection?.setRemoteDescription(RTCSessionDescription(offer['sdp'], offer['type']));

      final answer = await _peerConnection?.createAnswer();
      await _peerConnection?.setLocalDescription(answer!);
      SocketService.sendCallAnswer(fromUserId, answer?.toMap());
    });

    SocketService.onCallAnswer((answer) async {
      await _peerConnection?.setRemoteDescription(RTCSessionDescription(answer['sdp'], answer['type']));
    });

    SocketService.onIceCandidate((candidate) async {
      await _peerConnection?.addCandidate(RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']));
    });

    SocketService.onCallEnd((fromUserId) {
      _endCall();
    });
  }

  void endCall() {
    SocketService.sendCallEnd(remoteUserId.value);
    _endCall();
  }

  void _endCall() {
    inCall.value = false;
    _peerConnection?.close();
    localStream?.dispose();
    remoteStream?.dispose();
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
  }

  @override
  void onClose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.onClose();
  }
}
