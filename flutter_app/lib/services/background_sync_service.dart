import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../data/datasources/local/product_local_datasource.dart';
import '../data/datasources/remote/product_remote_datasource.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/usecases/get_all_products_usecase.dart';
import '../domain/usecases/sync_products_usecase.dart';

// Background task identifier
const syncTaskName = "backgroundProductSync";

/// Background callback dispatcher
/// This runs in a separate isolate, so we need to reinitialize everything
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('Background sync task started: $task');

      // Initialize Hive in background isolate
      await Hive.initFlutter();
      Hive.registerAdapter(ProductModelAdapter());
      Hive.registerAdapter(SyncActionAdapter());

      // Initialize local data source
      final localDataSource = ProductLocalDataSourceImpl();
      await localDataSource.init();

      // Initialize remote data source
      final remoteDataSource = ProductRemoteDataSourceImpl(
        dio: Dio(), // Use a simple HTTP client for background tasks
      );

      // Initialize repository
      final productRepository = ProductRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );

      // Initialize use cases
      final getAllProductsUseCase = GetAllProductsUseCase(productRepository);
      final syncProductsUseCase = SyncProductsUseCase(productRepository);

      // Check for unsynced products
      final products = await getAllProductsUseCase.execute();
      final unsyncedProducts = products.where((p) => !p.isSynced).toList();

      if (unsyncedProducts.isEmpty) {
        debugPrint('Background sync: No unsynced products found');
        return Future.value(true);
      }

      debugPrint(
          'Background sync: Found ${unsyncedProducts.length} unsynced products. Starting sync...');

      // Sync products
      await syncProductsUseCase.execute();

      debugPrint('Background sync: Successfully completed');
      return Future.value(true);
    } catch (e) {
      debugPrint('Background sync failed: $e');
      // Return false to retry later
      return Future.value(false);
    }
  });
}

class BackgroundSyncService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    // Register periodic task for background sync
    // - Runs every 15 minutes (minimum allowed by Android WorkManager)
    // - When app is in foreground: In-app timer handles sync every 2 minutes
    // - When app is minimized/background: This periodic task handles sync
    // Note: iOS background fetch runs at system-determined intervals
    await Workmanager().registerPeriodicTask(
      "backgroundSync",
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected, // Only when connected to internet
      ),
    );

    debugPrint(
        'Background sync service initialized - periodic sync every 15 minutes');
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }

  static Future<void> registerOneOffSync() async {
    // For immediate sync when app goes to background
    await Workmanager().registerOneOffTask(
      "oneOffSync",
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}
