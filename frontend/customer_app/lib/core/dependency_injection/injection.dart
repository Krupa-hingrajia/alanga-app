import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/secure_storage_service.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';

// Auth imports
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';

// Home imports
import '../../features/home/presentation/bloc/home_bloc.dart';

// Categories imports
import '../../features/categories/data/datasource/category_remote_datasource.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/presentation/bloc/category_bloc.dart';

// Products imports
import '../../features/products/data/datasource/product_remote_datasource.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';

// Wishlist imports
import '../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/presentation/bloc/wishlist_bloc.dart';

// Cart imports
import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/presentation/bloc/cart_cubit.dart';

// Address imports
import '../../features/addresses/data/datasources/address_remote_datasource.dart';
import '../../features/addresses/domain/repositories/address_repository.dart';
import '../../features/addresses/data/repositories/address_repository_impl.dart';
import '../../features/addresses/presentation/bloc/address_cubit.dart';

// Checkout imports
import '../../features/checkout/data/datasources/checkout_remote_datasource.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/presentation/bloc/checkout_cubit.dart';
import '../../features/checkout/presentation/bloc/order_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => LoginBloc(loginUseCase: sl()));
  sl.registerFactory(() => RegisterBloc(registerUseCase: sl()));
  sl.registerFactory(() => HomeBloc(categoryRepository: sl(), productRepository: sl()));
  sl.registerFactory(() => CategoryBloc(categoryRepository: sl()));
  sl.registerFactory(() => ProductBloc(productRepository: sl()));
  sl.registerLazySingleton(() => WishlistBloc(repository: sl()));
  sl.registerLazySingleton(() => CartCubit(repository: sl()));
  sl.registerLazySingleton(() => AddressCubit(repository: sl()));
  sl.registerLazySingleton(() => CheckoutCubit(repository: sl()));
  sl.registerLazySingleton(() => OrderCubit(repository: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), storageService: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDatasource: sl()),
  );
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(remoteDatasource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<CartRemoteDatasource>(
    () => CartRemoteDatasourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<AddressRemoteDatasource>(
    () => AddressRemoteDatasourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<CheckoutRemoteDatasource>(
    () => CheckoutRemoteDatasourceImpl(apiService: sl()),
  );

  // Core
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => ApiService(sl()));

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
