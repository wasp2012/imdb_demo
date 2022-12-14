import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'business_logic/internet_cubit/internet_cubit.dart';

import 'business_logic/auth_cubit/authentication_cubit.dart';
import 'business_logic/favorite_cubit/favorite_cubit.dart';

import 'business_logic/movies_cubitt/movie_detail_cubit/movie_details_cubit.dart';
import 'business_logic/movies_cubitt/movies_cubit/movies_cubit.dart';
import 'business_logic/profile_cubit/profile_cubit.dart';
import 'business_logic/theme_cubit/settings_cubit.dart';
import 'route/router.dart';
import 'shared/constants/strings.dart';
import 'shared/data/repo/account_repo/acc_repo.dart';
import 'shared/data/repo/auth_repo/auth_repo.dart';
import 'shared/data/repo/movies_repo/movies_repository.dart';
import 'shared/offline_data.dart';
import 'shared/web_services/network/account_web_services/web_service_for_account.dart';
import 'shared/web_services/network/auth_web_services/web_services_for_auth.dart';
import 'shared/web_services/network/movies_web_services/web_service_for_movies.dart';

final getIt = GetIt.instance;

void initGetIt() {
  getIt.allowReassignment = true;

//Movies
  getIt.registerLazySingleton<WebServicesForMovies>(
      () => WebServicesForMovies(createAndSetupDio()));

  getIt.registerLazySingleton<MoviesRepository>(() => MoviesRepository());

//Authentication
  getIt.registerLazySingleton<WebServicesForAuth>(
      () => WebServicesForAuth(createAndSetupDio()));

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());

//Account
  getIt.registerLazySingleton<WebServicesForAccount>(
      () => WebServicesForAccount(createAndSetupDio()));

  getIt.registerLazySingleton<AccountRepository>(() => AccountRepository());

//Cubits
  getIt.registerLazySingleton<MoviesCubit>(
      () => MoviesCubit(getIt<MoviesRepository>()));

  getIt.registerFactory<MovieDetailsCubit>(
      () => MovieDetailsCubit(getIt<MoviesRepository>()));

  getIt.registerSingletonAsync<FavoriteCubit>(() async {
    final allFavorite = FavoriteCubit(getIt<AccountRepository>());
    if (await SharedPrefs.checkValue(sessionIdKey) ||
        await SharedPrefs.checkValue(userIdKey)) {
      await allFavorite.emitGetFavoriteMovies();
      await allFavorite.emitGetAllWatchList();
    }
    return allFavorite;
  });

  getIt.registerLazySingleton<AuthenticationCubit>(
      () => AuthenticationCubit(getIt<AuthRepository>()));

  //    await authentication.emitGetRequestToken();

  getIt.registerSingletonAsync<ProfileCubit>(() async {
    final userDetail = ProfileCubit(getIt<AccountRepository>());
    if (await SharedPrefs.checkValue(sessionIdKey)) {
      await userDetail.emitGetUserDetails();
    }
    return userDetail;
  });

  getIt.registerSingletonAsync<SettingsCubit>(() async {
    final themeCubit = SettingsCubit();
    await themeCubit.getSavedTheme();
    return themeCubit;
  });

  getIt.registerSingletonAsync<SettingsCubit>(() async {
    final themeCubit = SettingsCubit();
    await themeCubit.getSavedTheme();
    return themeCubit;
  });

  getIt.registerFactory<InternetCubit>(
    () => InternetCubit(
      connectivity: Connectivity(),
    ),
  );

  //

  getIt.registerLazySingleton<AppRouter>(() => AppRouter());

// Alternatively you could write it if you don't like global variables
//   GetIt.I.registerSingleton<MoviesCubit>(MoviesCubit());
}

Dio createAndSetupDio() {
  Dio dio = Dio();

  dio
    ..options.connectTimeout = 60 * 1000
    ..options.receiveTimeout = 60 * 1000;
  dio.interceptors.add(LogInterceptor(
    responseBody: true,
    error: true,
    requestHeader: false,
    responseHeader: false,
    request: true,
    requestBody: true,
  ));

  return dio;
}
