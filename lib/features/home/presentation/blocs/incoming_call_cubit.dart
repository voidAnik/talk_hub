import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_hub/features/home/domain/repositories/home_repository.dart';

class IncomingCallCubit extends Cubit<String?> {
  final HomeRepository _repository;
  IncomingCallCubit(this._repository) : super(null);

  void startListeningForIncomingCalls() {
    _repository.listenIncomingCall().listen((response) {
      response.fold((_) {}, (callId) {
        emit(callId);
      });
    });
  }

  void stopListeningForIncomingCalls() {
    emit(null);
  }
}
