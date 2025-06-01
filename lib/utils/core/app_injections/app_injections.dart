import 'dart:async';

import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> initLocator() async {
  // Core & External dependencies
  // await CacheHelper.init();
  // // Registering repositories

  // await DioHelper.init();

  // getIt.registerSingleton<DioHelper>(DioHelper());
  // //DataSource && Clients
  // getIt.registerLazySingleton(
  //     () => DepositRemoteDataSource(getIt<DioHelper>().dio));

  // Repositories
  // getIt.registerFactory<AuthRepository>(
  //     () => AuthRepositoryImpl(getIt(), getIt()));

  // getIt.registerLazySingleton<DepositRepo>(
  //     () => DepositRepoImpl(getIt<DepositRemoteDataSource>()));

  // UseCases
  // getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  // Cubits
  // getIt.registerLazySingleton(() => NavigationCubit());
}
