import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:talk_hub/core/web_rtc/singnaling_service.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';

class CallScreen extends StatefulWidget {
  static const String path = '/call';
  final UserModel user;
  const CallScreen({super.key, required this.user});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Signaling? signaling;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool inCalling = false;
  String? roomId;

  @override
  void initState() {
    _connect();
    super.initState();
  }

  void _connect() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    if (signaling == null) {
      signaling = Signaling();
      signaling!.initiateCall(
          FirebaseAuth.instance.currentUser!.uid, widget.user.uid!, 'video');

      signaling?.onLocalStream = ((stream) {
        localRenderer.srcObject = stream;
      });

      signaling?.onAddRemoteStream = ((stream) {
        remoteRenderer.srcObject = stream;
      });

      signaling?.onRemoveRemoteStream = (() {
        remoteRenderer.srcObject = null;
      });

      signaling?.onDisconnect = (() {
        setState(() {
          inCalling = false;
          roomId = null;
        });
      });
    }
  }

  @override
  deactivate() {
    super.deactivate();
    localRenderer.dispose();
    remoteRenderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Firebase WebRTC'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: inCalling
            ? SizedBox(
                width: 200.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: () async {
                        /* await signaling?.hangUp(callId);
                setState(() {
                  roomId = null;
                  inCalling = false;
                });*/
                      },
                      tooltip: 'Hangup',
                      backgroundColor: Colors.red.shade700,
                      child: const Icon(Icons.call_end),
                    ),
                    FloatingActionButton(
                      onPressed: signaling?.muteMic,
                      tooltip: 'Mute Mic',
                      child: const Icon(Icons.mic_off),
                    )
                  ],
                ),
              )
            : null,
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(color: Colors.black54),
              child: RTCVideoView(remoteRenderer),
            ),
            Positioned(
              left: 20.0,
              top: 20.0,
              child: Container(
                width: 200.0,
                height: 100.0,
                decoration: const BoxDecoration(color: Colors.black54),
                child: RTCVideoView(localRenderer, mirror: true),
              ),
            ),
          ],
        ));
  }
}
