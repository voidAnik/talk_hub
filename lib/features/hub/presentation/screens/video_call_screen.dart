import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_hub/core/web_rtc/enums.dart';
import 'package:talk_hub/core/web_rtc/signaling_service.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';

class VideoCallScreen extends StatefulWidget {
  static const String path = '/video_call_screen';
  final UserModel? user;
  final String? callId;
  const VideoCallScreen({super.key, this.user, this.callId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Signaling? signaling;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool inCalling = false;

  @override
  void initState() {
    _connect();
    super.initState();
  }

  void _connect() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    if (signaling == null) {
      signaling = Signaling(MediaType.video);
      if (widget.user != null && widget.callId == null) {
        log('initiating call...');
        signaling!.initiateCall(
            FirebaseAuth.instance.currentUser!.uid, widget.user!.uid!);
      } else {
        log('receiving call...');
        signaling!.answerCall(widget.callId!);
      }

      signaling?.onAddLocalStream = ((stream) {
        setState(() {
          localRenderer.srcObject = stream;
        });
      });

      signaling?.onAddRemoteStream = ((stream) {
        setState(() {
          remoteRenderer.srcObject = stream;
        });
      });

      signaling?.onRemoveRemoteStream = (() {
        setState(() {
          remoteRenderer.srcObject = null;
        });
      });

      signaling?.onDisconnect = (() {
        /* setState(() {
          inCalling = false;
          roomId = null;
        });*/
        log('call disconnected');
        context.pop();
      });
    }
  }

  /*@override
  deactivate() {
    super.deactivate();
    localRenderer.dispose();
    remoteRenderer.dispose();
  }*/

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('In Call'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: 200.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () async {
                  if (signaling != null && signaling!.callId != null) {
                    await signaling?.hangUp(signaling!.callId!).then((_) {
                      Navigator.pop(context);
                    });
                  } else {
                    Navigator.pop(context);
                  }

                  /* setState(() {
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
        ),
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
