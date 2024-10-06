import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/core/use_case/use_case.dart';
import 'package:talk_hub/features/home/data/models/room_model.dart';
import 'package:talk_hub/features/home/domain/use_cases/get_rooms.dart';
import 'package:talk_hub/features/home/presentation/blocs/data_state.dart';

class GetRoomsCubit extends Cubit<DataState> {
  final GetRooms _getRooms;
  GetRoomsCubit(this._getRooms) : super(DataInitial());

  Future<void> call() async {
    emit(DataLoading());
    final responseOrFailure = await _getRooms(params: NoParams());
    responseOrFailure.fold((failure) {
      if (failure is FirebaseFailure) {
        emit(DataError(error: failure.message));
      } else {
        emit(const DataError(error: 'Unknown Failure'));
      }
    }, (data) {
      emit(DataSuccess<List<RoomModel>>(data: data));
    });
  }
}
