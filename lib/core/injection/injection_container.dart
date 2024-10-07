import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talk_hub/core/utils/network_info.dart';
import 'package:talk_hub/features/authentication/data/data_sources/user_remote_data_source.dart';
import 'package:talk_hub/features/authentication/data/repositories/user_repository.dart';
import 'package:talk_hub/features/authentication/domain/repositories/user_repository.dart';
import 'package:talk_hub/features/authentication/domain/use_cases/save_user.dart';
import 'package:talk_hub/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:talk_hub/features/home/data/repositories/home_repository_impl.dart';
import 'package:talk_hub/features/home/domain/repositories/home_repository.dart';
import 'package:talk_hub/features/home/domain/use_cases/get_rooms.dart';
import 'package:talk_hub/features/home/domain/use_cases/get_users.dart';
import 'package:talk_hub/features/home/presentation/blocs/get_rooms_cubit.dart';
import 'package:talk_hub/features/home/presentation/blocs/get_users_cubit.dart';
import 'package:talk_hub/features/home/presentation/blocs/incoming_call_cubit.dart';
import 'package:talk_hub/features/hub/presentation/blocs/mute_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //* Core

  getIt
    ..registerLazySingleton(() => InternetConnectionChecker())
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()))
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseAuth.instance);

  //* data providers
  getIt
    ..registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(getIt()))
    ..registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(getIt(), getIt()));

  //* Repositories
  getIt
    ..registerLazySingleton<UserRepository>(() => UserRepositoryImpl(getIt()))
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(getIt()));

  //* Use Cases
  getIt
    ..registerLazySingleton(() => SaveUser(getIt()))
    ..registerLazySingleton(() => GetUsers(getIt()))
    ..registerLazySingleton(() => GetRooms(getIt()));

  //* Blocs
  getIt
    ..registerFactory(() => GetUsersCubit(getIt()))
    ..registerFactory(() => GetRoomsCubit(getIt()))
    ..registerFactory(() => IncomingCallCubit(getIt()))
    ..registerFactory(() => MuteCubit());
}
