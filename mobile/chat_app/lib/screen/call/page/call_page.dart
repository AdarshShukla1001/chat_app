import 'package:chat_app/screen/call/controller/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallPage extends StatelessWidget {
  final CallController controller = Get.put(CallController());

  final String toUserId;
  final bool isCaller;

  CallPage({super.key, required this.toUserId, required this.isCaller});

  @override
  Widget build(BuildContext context) {
    if (isCaller) {
      controller.makeCall(toUserId);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Video Call')),
      body: Obx(() {
        return controller.inCall.value
            ? Stack(
                children: [
                  RTCVideoView(controller.remoteRenderer),
                  Positioned(
                    top: 20,
                    right: 20,
                    width: 120,
                    height: 160,
                    child: Container(color: Colors.black54, child: RTCVideoView(controller.localRenderer, mirror: true)),
                  ),
                  Positioned(
                    bottom: 50,
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    child: FloatingActionButton(backgroundColor: Colors.red, onPressed: controller.endCall, child: Icon(Icons.call_end)),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator());
      }),
    );
  }
}
