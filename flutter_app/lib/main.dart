import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'data/datasources/local/product_local_datasource.dart';
import 'data/datasources/remote/barcode_lookup_datasource.dart';
import 'data/datasources/remote/product_remote_datasource.dart';
import 'data/models/product_model.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/create_product_usecase.dart';
import 'domain/usecases/delete_product_usecase.dart';
import 'domain/usecases/get_all_products_usecase.dart';
import 'domain/usecases/get_product_by_barcode_usecase.dart';
import 'domain/usecases/lookup_barcode_usecase.dart';
import 'domain/usecases/sync_products_usecase.dart';
import 'domain/usecases/update_product_usecase.dart';
import 'presentation/controllers/barcode_scanner_controller.dart';
import 'presentation/controllers/product_controller.dart';
import 'presentation/pages/barcode_scanner/barcode_scanner_page.dart';
import 'presentation/pages/product_form/product_form_page.dart';
import 'presentation/pages/product_list/product_list_page.dart';
import 'services/background_sync_service.dart';
import 'services/barcode_service.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(SyncActionAdapter());

  // Initialize local data source
  final localDataSource = ProductLocalDataSourceImpl();
  await localDataSource.init();

  // Setup dependencies
  await setupDependencies(localDataSource);

  // Initialize background sync
  await BackgroundSyncService.initialize();

  runApp(const MyApp());
}

Future<void> setupDependencies(ProductLocalDataSource localDataSource) async {
  // Data sources
  final remoteDataSource = ProductRemoteDataSourceImpl(
    client: http.Client(),
  );

  // Barcode Lookup Data Source (using Open Food Facts API)
  // You can switch to UPCItemDBDataSourceImpl or CustomBackendDataSourceImpl
  final barcodeLookupDataSource = OpenFoodFactsDataSourceImpl(
    client: http.Client(),
  );

  // Repository
  final productRepository = ProductRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
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

  // Initialize services
  Get.find<ConnectivityService>().onInit();
  Get.find<SyncService>().onInit();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inventory Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const ProductListPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => ProductController(
                  getAllProductsUseCase: Get.find<GetAllProductsUseCase>(),
                  getProductByBarcodeUseCase:
                      Get.find<GetProductByBarcodeUseCase>(),
                  lookupBarcodeUseCase: Get.find<LookupBarcodeUseCase>(),
                  createProductUseCase: Get.find<CreateProductUseCase>(),
                  updateProductUseCase: Get.find<UpdateProductUseCase>(),
                  deleteProductUseCase: Get.find<DeleteProductUseCase>(),
                  syncProductsUseCase: Get.find<SyncProductsUseCase>(),
                  syncService: Get.find<SyncService>(),
                ));
          }),
        ),
        GetPage(
          name: '/product-form',
          page: () => const ProductFormPage(),
          // Use the same ProductController instance
        ),
        GetPage(
          name: '/barcode-scanner',
          page: () => const BarcodeScannerPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => BarcodeScannerController(
                  barcodeService: Get.find<BarcodeService>(),
                ));
          }),
        ),
      ],
    );
  }
}
