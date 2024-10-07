import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_hub/config/theme/colors.dart';
import 'package:talk_hub/core/constants/strings.dart';
import 'package:talk_hub/core/extensions/context_extension.dart';
import 'package:talk_hub/core/injection/injection_container.dart';
import 'package:talk_hub/core/web_rtc/enums.dart';
import 'package:talk_hub/features/authentication/presentation/screens/user_profile_screen.dart';
import 'package:talk_hub/features/home/presentation/blocs/incoming_call_cubit.dart';
import 'package:talk_hub/features/home/presentation/widgets/room_grid_widget.dart';
import 'package:talk_hub/features/home/presentation/widgets/user_list_widget.dart';
import 'package:talk_hub/features/hub/presentation/screens/audio_call_screen.dart';
import 'package:talk_hub/features/hub/presentation/screens/video_call_screen.dart';
import 'package:talk_hub/features/hub/presentation/widgets/incoming_call_dialogue.dart';

class HomeScreen extends StatelessWidget {
  static const String path = '/home_screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<IncomingCallCubit>()..startListeningForIncomingCalls(),
      child: BlocListener<IncomingCallCubit, String?>(
        listener: (context, callId) {
          if (callId != null) {
            log('incoming call...... $callId');
            _showIncomingCallDialog(context, callId);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.title,
                style: GoogleFonts.aldrich(color: primaryColor),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    onPressed: () => context.push(UserProfileScreen.path),
                    icon: const Icon(FontAwesomeIcons.user)),
              )
            ],
          ),
          body: _createBody(context),
        ),
      ),
    );
  }

  _createBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppStrings.roomsTitle,
              style: context.textStyle.headlineMedium,
            ),
          ),
          const RoomGrid(), // Room Grid
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppStrings.usersTitle,
              style: context.textStyle.headlineMedium,
            ),
          ),
          const UserList(), // User List
        ],
      ),
    );
  }

  void _showIncomingCallDialog(BuildContext context, String callId) async {
    await context
        .read<IncomingCallCubit>()
        .getCallerInfo(callId)
        .then((callInfo) {
      log('callerInfo: $callInfo');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return IncomingCallDialog(
            caller: callInfo?.user,
            onAccept: () {
              Navigator.of(context).pop();
              log('Call accepted');
              if (callInfo?.callType == MediaType.video.name) {
                context.push(VideoCallScreen.path, extra: callId);
              } else {
                context.push(AudioCallScreen.path,
                    extra: (callInfo?.user, callId));
              }
            },
            onDecline: () {
              Navigator.of(context).pop();
              log('Call declined');
            },
          );
        },
      );
    });
  }
}
