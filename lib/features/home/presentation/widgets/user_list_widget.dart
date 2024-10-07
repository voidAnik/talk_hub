import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:talk_hub/core/extensions/context_extension.dart';
import 'package:talk_hub/core/injection/injection_container.dart';
import 'package:talk_hub/core/widgets/error_widget.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/home/presentation/blocs/data_state.dart';
import 'package:talk_hub/features/home/presentation/blocs/get_users_cubit.dart';
import 'package:talk_hub/features/hub/presentation/screens/audio_call_screen.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GetUsersCubit>()..call(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GetUsersCubit, DataState>(
          builder: (context, state) {
            if (state is DataLoading) {
              return const CircularProgressIndicator();
            } else if (state is DataSuccess) {
              List<UserModel> users = state.data;
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return GestureDetector(
                      onTap: () {
                        //context.push(VideoCallScreen.path, extra: user);
                        context.push(AudioCallScreen.path, extra: user);
                      },
                      child: _createListTile(user, context));
                },
              );
            } else if (state is DataError) {
              return ErrorMessage(message: state.error);
            }

            return const ErrorMessage(message: 'Unknown Error');
          },
        ),
      ),
    );
  }

  ListTile _createListTile(UserModel user, BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
            user.photoUrl ?? 'https://randomuser.me/api/portraits/men/1.jpg'),
      ),
      title: Text(
        user.name ?? 'Unknown User',
        style: context.textStyle.titleMedium,
      ),
      subtitle: Text(
        user.email ?? '',
        style: context.textStyle.bodySmall,
      ),
      trailing: user.isOnline == true
          ? const Icon(Icons.circle, color: Colors.green, size: 12)
          : const Icon(Icons.circle, color: Colors.red, size: 12),
    );
  }
}
