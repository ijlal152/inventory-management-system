import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/barcode_lookup_datasource.dart';
import '../../data/datasources/remote/product_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_product_by_barcode_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/lookup_barcode_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/sync_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/product_controller.dart';
import '../../services/barcode_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/sync_service.dart';
import '../network/authenticated_http_client.dart';

class DependencyInjection {
  static Future<void> init(
    ProductLocalDataSource localDataSource,
    FlutterSecureStorage secureStorage,
    SharedPreferences sharedPreferences,
  ) async {
    // Auth Local Data Source
    final authLocalDataSource = AuthLocalDataSourceImpl(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
    );

    // Create authenticated HTTP client
    final authenticatedClient = AuthenticatedHttpClient(
      client: http.Client(),
      authDataSource: authLocalDataSource,
    );

    // Auth Remote Data Source
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      client: http.Client(), // Use regular client for auth endpoints
    );

    // Auth Repository
    final authRepository = AuthRepositoryImpl(
      localDataSource: authLocalDataSource,
      remoteDataSource: authRemoteDataSource,
    );
    Get.put<AuthRepository>(authRepository);

    // Auth Use Cases
    Get.put(LoginUseCase(authRepository));
    Get.put(RegisterUseCase(authRepository));
    Get.put(LogoutUseCase(authRepository));
    Get.put(GetCurrentUserUseCase(authRepository));
    Get.put(CheckAuthStatusUseCase(authRepository));

    // Auth Controller
    Get.put(
      AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
        checkAuthStatusUseCase: Get.find<CheckAuthStatusUseCase>(),
      ),
    );

    // Product Remote Data Sources (now using authenticated client)
    final productRemoteDataSource = ProductRemoteDataSourceImpl(
      client: authenticatedClient,
    );

    // Barcode Lookup Data Source (using Open Food Facts API)
    // You can switch to UPCItemDBDataSourceImpl or CustomBackendDataSourceImpl
    final barcodeLookupDataSource = OpenFoodFactsDataSourceImpl(
      client: http.Client(),
    );

    // Product Repository
    final productRepository = ProductRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: productRemoteDataSource,
    );
    Get.put<ProductRepository>(productRepository);

    // Use Cases
    Get.put(GetAllProductsUseCase(productRepository));
    Get.put(GetProductByBarcodeUseCase(productRepository));
    Get.put(LookupBarcodeUseCase(barcodeLookupDataSource));
    Get.put(CreateProductUseCase(productRepository));
    Get.put(UpdateProductUseCase(productRepository));
    Get.put(DeleteProductUseCase(productRepository));
    Get.put(SyncProductsUseCase(productRepository));

    // Services
    Get.put(ConnectivityService());
    Get.put(BarcodeService());
    Get.put(
      SyncService(
        productRepository: productRepository,
        connectivityService: Get.find<ConnectivityService>(),
      ),
    );

    // ProductController
    Get.put(
      ProductController(
        getAllProductsUseCase: Get.find<GetAllProductsUseCase>(),
        getProductByBarcodeUseCase: Get.find<GetProductByBarcodeUseCase>(),
        lookupBarcodeUseCase: Get.find<LookupBarcodeUseCase>(),
        createProductUseCase: Get.find<CreateProductUseCase>(),
        updateProductUseCase: Get.find<UpdateProductUseCase>(),
        deleteProductUseCase: Get.find<DeleteProductUseCase>(),
        syncProductsUseCase: Get.find<SyncProductsUseCase>(),
        syncService: Get.find<SyncService>(),
      ),
    );

    // Initialize services
    Get.find<ConnectivityService>().onInit();
    Get.find<SyncService>().onInit();
  }
}
