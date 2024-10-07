import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talk_hub/features/home/domain/repositories/home_repository.dart';
import 'package:talk_hub/features/hub/data/models/incoming_call.dart';

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

  Future<IncomingCall?> getCallerInfo(String callId) async {
    final responseOrFailure = await _repository.getCallerInfo(callId: callId);
    final value = responseOrFailure.fold((_) {
      log('fetching caller info failed');
      return null;
    }, (caller) {
      log('fetching success $caller');
      return caller;
    });

    return value;
  }
}
