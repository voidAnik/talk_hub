import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/core/use_case/use_case.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/home/domain/use_cases/get_users.dart';
import 'package:talk_hub/features/home/presentation/blocs/data_state.dart';

class GetUsersCubit extends Cubit<DataState> {
  final GetUsers _getUsers;
  GetUsersCubit(this._getUsers) : super(DataInitial());

  Future<void> call() async {
    emit(DataLoading());
    final responseOrFailure = await _getUsers(params: NoParams());
    responseOrFailure.fold((failure) {
      if (failure is FirebaseFailure) {
        emit(DataError(error: failure.message));
      } else {
        emit(const DataError(error: 'Unknown Failure'));
      }
    }, (data) {
      emit(DataSuccess<List<UserModel>>(data: data));
    });
  }
}
