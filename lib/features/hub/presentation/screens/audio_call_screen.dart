import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_hub/core/extensions/context_extension.dart';
import 'package:talk_hub/core/injection/injection_container.dart';
import 'package:talk_hub/core/web_rtc/enums.dart';
import 'package:talk_hub/core/web_rtc/signaling_service.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/hub/presentation/blocs/mute_cubit.dart';

class AudioCallScreen extends StatefulWidget {
  static const String path = '/audio_call_screen';
  final UserModel? user;
  final String? callId;

  const AudioCallScreen({super.key, this.user, this.callId});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  Signaling? signaling;

  @override
  void initState() {
    _connect();
    super.initState();
  }

  void _connect() async {
    if (signaling == null) {
      signaling = Signaling(MediaType.audio);
      if (widget.user != null && widget.callId == null) {
        log('initiating call...');
        signaling!.initiateCall(
            FirebaseAuth.instance.currentUser!.uid, widget.user!.uid!);
      } else {
        log('receiving call...');
        signaling!.answerCall(widget.callId!);
      }

      signaling?.onDisconnect = (() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MuteCubit>(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('In Call'),
            centerTitle: true,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
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
                BlocBuilder<MuteCubit, bool>(
                  builder: (context, isMute) {
                    return FloatingActionButton(
                      onPressed: () {
                        signaling?.muteMic;
                        context.read<MuteCubit>().toggleMic();
                      },
                      tooltip: 'Mute Mic',
                      child: isMute
                          ? const Icon(Icons.mic_off)
                          : const Icon(Icons.mic),
                    );
                  },
                )
              ],
            ),
          ),
          body: _createBody(context)),
    );
  }

  _createBody(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      width: context.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            child: Image.network(widget.user!.photoUrl ??
                'https://randomuser.me/api/portraits/men/1.jpg'),
          ),
          SizedBox(
            height: context.height * 0.02,
          ),
          Text(widget.user!.name ?? 'Unknown User'),
          SizedBox(
            height: context.height * 0.02,
          ),
          Text(widget.user!.email!),
        ],
      ),
    );
  }
}
