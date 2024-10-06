import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_hub/core/constants/strings.dart';
import 'package:talk_hub/core/extensions/context_extension.dart';
import 'package:talk_hub/core/injection/injection_container.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/authentication/presentation/screens/user_profile_screen.dart';
import 'package:talk_hub/features/home/data/models/room_model.dart';
import 'package:talk_hub/features/home/presentation/blocs/incoming_call_cubit.dart';
import 'package:talk_hub/features/home/presentation/widgets/room_grid_widget.dart';
import 'package:talk_hub/features/home/presentation/widgets/user_list_widget.dart';

class HomeScreen extends StatelessWidget {
  static const String path = '/home_screen';

  // Mock Data for Rooms
  final List<RoomModel> mockRooms = [
    RoomModel(id: 'room1', name: 'Room 1', description: 'General Discussion'),
    RoomModel(id: 'room2', name: 'Room 2', description: 'Flutter Development'),
    RoomModel(id: 'room3', name: 'Room 3', description: 'WebRTC Testing'),
  ];

// Mock Data for Users
  final List<UserModel> mockUsers = [
    UserModel(
      name: 'Alice Johnson',
      email: 'alice@example.com',
      photoUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      uid: 'user1',
      isEmailVerified: true,
      isOnline: true,
    ),
    UserModel(
      name: 'Bob Smith',
      email: 'bob@example.com',
      photoUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      uid: 'user2',
      isEmailVerified: true,
      isOnline: false,
    ),
    // Add more users...
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<IncomingCallCubit>()..startListeningForIncomingCalls(),
      child: BlocListener<IncomingCallCubit, String?>(
        listener: (context, callId) {
          if (callId != null) {
            log('incoming call...... $callId');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.title,
                style: GoogleFonts.aldrich(color: Colors.white),
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
}
