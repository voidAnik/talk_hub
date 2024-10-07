import 'package:flutter_bloc/flutter_bloc.dart';

class MuteCubit extends Cubit<bool> {
  MuteCubit() : super(false);

  void toggleMic() {
    emit(!state);
  }
}
