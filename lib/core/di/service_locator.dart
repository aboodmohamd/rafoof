import 'package:dio/dio.dart';
import 'package:rafoof/core/database/app_database.dart';
import 'package:rafoof/core/database/database_helper.dart';
import 'package:rafoof/core/network/api_client.dart';
import 'package:rafoof/core/network/app_interceptors.dart';
import 'package:rafoof/core/services/app_preferences.dart';
import 'package:rafoof/features/auth/data/repositories/auth_repository.dart';
import 'package:rafoof/features/categories/data/repositories/category_repository.dart';
import 'package:rafoof/features/checkout/data/repositories/checkout_repository.dart';
import 'package:rafoof/features/products/data/repositories/product_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(sl<DatabaseHelper>()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton<AppPreferences>(
    () => AppPreferences(sl(), sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<AppInterceptors>(
    () => AppInterceptors(appPreferences: sl(), dio: sl<Dio>()),
  );
  sl.registerLazySingleton<ApiConsumer>(
    () => ApiClient(dioClient: sl(), interceptors: sl<AppInterceptors>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiConsumer: sl<ApiConsumer>(),
      appPreferences: sl<AppPreferences>(),
    ),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepository(apiConsumer: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(apiConsumer: sl<ApiConsumer>()),
  );
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepository(apiConsumer: sl<ApiConsumer>()),
  );
}
