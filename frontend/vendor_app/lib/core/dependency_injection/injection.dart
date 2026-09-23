import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/secure_storage_service.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/login/login_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';

// Categories imports
import '../../features/categories/data/datasource/category_remote_datasource.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/presentation/bloc/category_bloc.dart';

// Brands imports
import '../../features/brands/data/datasource/brand_remote_datasource.dart';
import '../../features/brands/domain/repositories/brand_repository.dart';
import '../../features/brands/data/repositories/brand_repository_impl.dart';
import '../../features/brands/presentation/bloc/brand_bloc.dart';

// Products imports
import '../../features/products/data/datasource/product_remote_datasource.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';

// SubCategories imports
import '../../features/sub_categories/data/datasource/sub_category_remote_datasource.dart';
import '../../features/sub_categories/domain/repositories/sub_category_repository.dart';
import '../../features/sub_categories/data/repositories/sub_category_repository_impl.dart';
import '../../features/sub_categories/presentation/bloc/sub_category_bloc.dart';

// Inventory imports
import '../../features/inventory/data/datasource/inventory_remote_datasource.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';

// Shipping imports
import '../../features/shipping/data/datasource/shipping_remote_datasource.dart';
import '../../features/shipping/domain/repositories/shipping_repository.dart';
import '../../features/shipping/data/repositories/shipping_repository_impl.dart';
import '../../features/shipping/presentation/bloc/shipping_bloc.dart';

// Orders imports
import '../../features/orders/data/datasource/vendor_order_remote_datasource.dart';
import '../../features/orders/domain/repositories/vendor_order_repository.dart';
import '../../features/orders/data/repositories/vendor_order_repository_impl.dart';
import '../../features/orders/presentation/bloc/vendor_order_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => LoginBloc(loginUseCase: sl()));
  sl.registerFactory(() => RegisterBloc(registerUseCase: sl()));
  sl.registerFactory(() => ForgotPasswordBloc(authRepository: sl()));
  sl.registerFactory(() => CategoryBloc(categoryRepository: sl()));
  sl.registerFactory(() => BrandBloc(brandRepository: sl()));
  sl.registerFactory(() => ProductBloc(productRepository: sl()));
  sl.registerFactory(() => SubCategoryBloc(subCategoryRepository: sl()));
  sl.registerFactory(() => InventoryBloc(inventoryRepository: sl()));
  sl.registerFactory(() => ShippingBloc(shippingRepository: sl()));
  sl.registerFactory(() => VendorOrderBloc(repository: sl()));

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
  sl.registerLazySingleton<BrandRepository>(
    () => BrandRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SubCategoryRepository>(
    () => SubCategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ShippingRepository>(
    () => ShippingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<VendorOrderRepository>(
    () => VendorOrderRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<BrandRemoteDataSource>(
    () => BrandRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<SubCategoryRemoteDataSource>(
    () => SubCategoryRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<ShippingRemoteDataSource>(
    () => ShippingRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<VendorOrderRemoteDataSource>(
    () => VendorOrderRemoteDataSourceImpl(apiService: sl()),
  );

  // Core
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => ApiService(sl()));

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
