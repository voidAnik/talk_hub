import 'package:dartz/dartz.dart';
import 'package:talk_hub/core/error/failures.dart';
import 'package:talk_hub/core/use_case/use_case.dart';
import 'package:talk_hub/features/authentication/data/models/user_model.dart';
import 'package:talk_hub/features/home/domain/repositories/home_repository.dart';

class GetUsers extends UseCase<List<UserModel>, NoParams> {
  final HomeRepository _repository;

  GetUsers(this._repository);

  @override
  Future<Either<Failure, List<UserModel>>> call({required NoParams params}) {
    return _repository.getUsers();
  }
}
