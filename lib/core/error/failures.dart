import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({this.properties = const <dynamic>[]});

  final List properties;

  @override
  List<Object> get props => [properties];
}

class NoInternetFailure extends Failure {
  final String message;

  const NoInternetFailure({required this.message});
}

class FirebaseFailure extends Failure {
  final String message;

  const FirebaseFailure({required this.message});
}

class InternalFailure extends Failure {
  final String error;

  const InternalFailure({required this.error});
}
