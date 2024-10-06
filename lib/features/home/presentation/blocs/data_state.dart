import 'package:equatable/equatable.dart';

abstract class DataState extends Equatable {
  final List _props;

  const DataState([this._props = const <dynamic>[]]);

  @override
  List<Object> get props => [_props];
}

class DataInitial extends DataState {}

class DataLoading extends DataState {}

class DataSuccess<T> extends DataState {
  final T data;

  const DataSuccess({
    required this.data,
  });

  @override
  List<Object> get props => [data as Object];
}

class DataError extends DataState {
  final String error;

  const DataError({required this.error});

  @override
  List<Object> get props => [error];
}
