import 'dart:developer';

import 'package:get/get.dart';

import '../domain/repositories/product_repository.dart';
import 'connectivity_service.dart';

class SyncService extends GetxService {
  final ProductRepository productRepository;
  final ConnectivityService connectivityService;

  final RxBool isSyncing = false.obs;
  final RxString lastSyncTime = ''.obs;

  SyncService({
    required this.productRepository,
    required this.connectivityService,
  });

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    connectivityService.isConnected.listen((isConnected) {
      if (isConnected && !isSyncing.value) {
        syncPendingChanges();
      }
    });
  }

  Future<void> syncPendingChanges() async {
    if (isSyncing.value) return;
    if (!connectivityService.isConnected.value) return;

    try {
      isSyncing.value = true;
      await productRepository.syncProducts();
      lastSyncTime.value = DateTime.now().toIso8601String();
    } catch (e) {
      log('Sync error: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> forceSyncRetry() async {
    await syncPendingChanges();
  }
}
