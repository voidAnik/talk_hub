import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:talk_hub/core/utils/network_info.dart';
import 'package:talk_hub/features/authentication/data/data_sources/user_remote_data_source.dart';
import 'package:talk_hub/features/authentication/data/repositories/user_repository.dart';
import 'package:talk_hub/features/authentication/domain/repositories/user_repository.dart';
import 'package:talk_hub/features/authentication/domain/use_cases/save_user.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //* Core

  getIt
    ..registerLazySingleton(() => InternetConnectionChecker())
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()))
    ..registerLazySingleton(() => FirebaseFirestore.instance);

  //* data providers
  getIt
    ..registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(getIt()));

  //* Repositories
  getIt
    ..registerLazySingleton<UserRepository>(() => UserRepositoryImpl(getIt()));

  //* Use Cases
  getIt..registerLazySingleton(() => SaveUser(getIt()));

  //* Blocs
  /*getIt
    ..registerFactory(()=> TrendingMoviesCubit(getIt()));*/
}
