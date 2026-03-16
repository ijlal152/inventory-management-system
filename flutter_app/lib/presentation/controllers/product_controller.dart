import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_all_products_usecase.dart';
import '../../domain/usecases/get_product_by_barcode_usecase.dart';
import '../../domain/usecases/lookup_barcode_usecase.dart';
import '../../domain/usecases/sync_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../services/sync_service.dart';

class ProductController extends GetxController with WidgetsBindingObserver {
  final GetAllProductsUseCase getAllProductsUseCase;
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final LookupBarcodeUseCase lookupBarcodeUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final SyncProductsUseCase syncProductsUseCase;
  final SyncService syncService;

  ProductController({
    required this.getAllProductsUseCase,
    required this.getProductByBarcodeUseCase,
    required this.lookupBarcodeUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.syncProductsUseCase,
    required this.syncService,
  });

  // Product List State
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Product Form State
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final barcodeController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxBool isSaving = false.obs;
  Product? existingProduct;

  // Auto-sync timer
  Timer? _autoSyncTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadProducts();
    _startAutoSync();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSyncTimer?.cancel();
    nameController.dispose();
    barcodeController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Trigger background sync when app goes to background/inactive
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _onAppMinimized();
    }
  }

  void _onAppMinimized() {
    // Check if there are unsynced products
    final unsyncedProducts = products.where((p) => !p.isSynced).toList();

    if (unsyncedProducts.isNotEmpty) {
      print(
          'App minimized with ${unsyncedProducts.length} unsynced products. Background sync will handle it.');
      // Background sync will be handled by periodic WorkManager task
      // No immediate sync - will happen within 2-3 minutes
    }
  }

  // ==================== Auto Sync ====================

  void _startAutoSync() {
    // Check every 2 minutes for unsynced records and sync them
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _autoSyncUnsynced();
    });
  }

  Future<void> _autoSyncUnsynced() async {
    try {
      // Check if there are any unsynced products
      final unsyncedProducts = products.where((p) => !p.isSynced).toList();

      if (unsyncedProducts.isEmpty) {
        print('Auto-sync: No unsynced products found');
        return;
      }

      print(
          'Auto-sync: Found ${unsyncedProducts.length} unsynced products. Starting sync...');

      // Sync products using use case
      await syncProductsUseCase.execute();

      // Reload products to show updated sync status
      await loadProducts();

      print('Auto-sync: Successfully synced products');

      // Show subtle notification that sync completed
      Get.snackbar(
        'Synced',
        '${unsyncedProducts.length} product(s) synced to server',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Auto-sync failed: $e');
      // Silently fail - will retry on next interval
    }
  }

  // ==================== Product List Methods ====================

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final loadedProducts = await getAllProductsUseCase.execute();
      products.value = loadedProducts;
    } catch (e) {
      errorMessage.value = 'Failed to load products: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String localId) async {
    try {
      // 1. Delete from local database first
      await deleteProductUseCase.execute(localId);

      // 2. Reload products to update UI immediately
      await loadProducts();

      Get.snackbar(
        'Success',
        'Product deleted. Will sync within 2-3 minutes.',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }

  Future<void> syncNow() async {
    await syncService.forceSyncRetry();
    await loadProducts();
  }

  void navigateToAddProduct() async {
    _clearForm();
    existingProduct = null;
    final result = await Get.toNamed('/product-form');
    // Reload products if a product was saved
    if (result == true) {
      await loadProducts();
    }
  }

  void navigateToEditProduct(Product product) async {
    existingProduct = product;
    _populateForm(product);
    final result = await Get.toNamed('/product-form', arguments: product);
    // Reload products if a product was updated
    if (result == true) {
      await loadProducts();
    }
  }

  // ==================== Product Form Methods ====================

  void initForm(Product? product) {
    existingProduct = product;
    if (product != null) {
      _populateForm(product);
    } else {
      _clearForm();
    }
  }

  void _populateForm(Product product) {
    nameController.text = product.name;
    barcodeController.text = product.barcode ?? '';
    priceController.text = product.price.toString();
    quantityController.text = product.quantity.toString();
    descriptionController.text = product.description ?? '';
  }

  void _clearForm() {
    nameController.clear();
    barcodeController.clear();
    priceController.clear();
    quantityController.clear();
    descriptionController.clear();
  }

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSaving.value = true;

      if (existingProduct != null) {
        // Update existing product
        final updatedProduct = existingProduct!.copyWith(
          name: nameController.text.trim(),
          barcode: barcodeController.text.trim().isEmpty
              ? null
              : barcodeController.text.trim(),
          price: double.parse(priceController.text),
          quantity: int.parse(quantityController.text),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          updatedAt: DateTime.now(),
        );

        // 1. Save to local database first
        await updateProductUseCase.execute(updatedProduct);

        // 2. Go back and show success immediately
        Get.back(result: true); // Signal that product was saved
        Get.snackbar(
          'Success',
          'Product saved. Will sync within 2-3 minutes.',
          duration: const Duration(seconds: 2),
        );
      } else {
        // Create new product
        final newProduct = Product(
          localId: const Uuid().v4(),
          name: nameController.text.trim(),
          barcode: barcodeController.text.trim().isEmpty
              ? null
              : barcodeController.text.trim(),
          price: double.parse(priceController.text),
          quantity: int.parse(quantityController.text),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          syncAction: SyncAction.create,
        );

        // 1. Save to local database first
        await createProductUseCase.execute(newProduct);

        // 2. Go back and show success immediately
        Get.back(result: true); // Signal that product was saved
        Get.snackbar(
          'Success',
          'Product saved. Will sync within 2-3 minutes.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: $e');
    } finally {
      isSaving.value = false;
    }
  }

  void openBarcodeScanner() async {
    final barcode = await Get.toNamed('/barcode-scanner');

    if (barcode != null && barcode is String) {
      barcodeController.text = barcode;

      // Show loading indicator
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Looking up product...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        // First, try to fetch from external barcode API
        final lookupResult = await lookupBarcodeUseCase.execute(barcode);

        Get.back(); // Close loading dialog

        if (lookupResult != null && lookupResult.productName != null) {
          // Product found in external database - auto-fill the form
          nameController.text = lookupResult.productName!;
          if (lookupResult.price != null) {
            priceController.text = lookupResult.price.toString();
          }
          quantityController.text = '1'; // Default quantity to 1

          // Combine brand and description if available
          String description = '';
          if (lookupResult.brand != null) {
            description += 'Brand: ${lookupResult.brand}\n';
          }
          if (lookupResult.description != null) {
            description += lookupResult.description!;
          }
          descriptionController.text = description.trim();

          Get.snackbar(
            'Product Found! ✓',
            '${lookupResult.productName} - Auto-filled from product database',
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green[100],
            colorText: Colors.green[900],
          );
        } else {
          // Not found in external API, try local database
          final localProduct =
              await getProductByBarcodeUseCase.execute(barcode);

          if (localProduct != null) {
            // Found in local database
            nameController.text = localProduct.name;
            priceController.text = localProduct.price.toString();
            quantityController.text = '1';
            descriptionController.text = localProduct.description ?? '';

            Get.snackbar(
              'Product Found (Local)',
              '${localProduct.name} - From your inventory',
              duration: const Duration(seconds: 2),
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.blue[100],
            );
          } else {
            // Product not found anywhere - manual entry required
            Get.snackbar(
              'New Product',
              'Barcode: $barcode\nProduct not found. Please enter details manually.',
              duration: const Duration(seconds: 3),
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange[100],
            );
          }
        }
      } catch (e) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Lookup Failed',
          'Could not fetch product details. Please enter manually.\nError: $e',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[100],
        );
      }
    }
  }
}
