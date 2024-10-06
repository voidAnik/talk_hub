import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_hub/core/extensions/context_extension.dart';
import 'package:talk_hub/core/injection/injection_container.dart';
import 'package:talk_hub/core/widgets/error_widget.dart';
import 'package:talk_hub/features/home/domain/entities/room.dart';
import 'package:talk_hub/features/home/presentation/blocs/data_state.dart';
import 'package:talk_hub/features/home/presentation/blocs/get_rooms_cubit.dart';

class RoomGrid extends StatelessWidget {
  const RoomGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GetRoomsCubit>()..call(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<GetRoomsCubit, DataState>(
          builder: (context, state) {
            if (state is DataLoading) {
              return const CircularProgressIndicator();
            } else if (state is DataSuccess) {
              List<Room> rooms = state.data;
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return GestureDetector(
                    onTap: () {
                      // Handle room tap, e.g., navigate to the room
                    },
                    child: _createItem(room, context),
                  );
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

  Card _createItem(Room room, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              room.name,
              style: context.textStyle.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              room.description,
              textAlign: TextAlign.center,
              style: context.textStyle.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
