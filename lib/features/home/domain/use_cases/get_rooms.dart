import 'package:dartz/dartz.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/core/use_case/use_case.dart';
import 'package:talk_hub/features/home/data/models/room_model.dart';
import 'package:talk_hub/features/home/domain/repositories/home_repository.dart';

class GetRooms extends UseCase<List<RoomModel>, NoParams> {
  final HomeRepository _repository;

  GetRooms(this._repository);

  @override
  Future<Either<Failure, List<RoomModel>>> call({required NoParams params}) {
    return _repository.getRooms();
  }
}
