import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/connectivity_service.dart';
import '../../../services/sync_service.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';

class ProductListPage extends GetView<ProductController> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Unsynced count badge
          Obx(() {
            final unsyncedCount = controller.products
                .where((p) => !p.isSynced)
                .length;
            if (unsyncedCount > 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Chip(
                  label: Text(
                    '$unsyncedCount pending',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(0),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Connectivity indicator
          Obx(() {
            final isConnected =
                Get.find<ConnectivityService>().isConnected.value;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: isConnected ? 'Online' : 'Offline',
                child: Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
            );
          }),
          // Sync button
          Obx(() {
            final isSyncing = Get.find<SyncService>().isSyncing.value;
            return IconButton(
              icon: isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
              onPressed: isSyncing ? null : controller.syncNow,
              tooltip: 'Sync now',
            );
          }),
          // User menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context, authController);
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Obx(() {
                    final user = authController.currentUser.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.loadProducts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No products yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Tap + to add your first product'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadProducts,
          child: ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              final isSynced = product.isSynced;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: isSynced ? 2 : 4,
                color: isSynced ? null : Colors.orange.shade50,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSynced ? null : Colors.orange,
                    child: Text(product.name[0].toUpperCase()),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(product.name)),
                      if (!isSynced)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'LOCAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.barcode != null)
                        Text('Barcode: ${product.barcode}'),
                      Text(
                        'Price: \$${product.price.toStringAsFixed(2)} | Qty: ${product.quantity}',
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isSynced ? Icons.cloud_done : Icons.sync_problem,
                            size: 14,
                            color: isSynced ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSynced ? 'Synced to server' : 'Waiting to sync',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSynced ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        controller.navigateToEditProduct(product);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, product.localId);
                      }
                    },
                  ),
                  onTap: () => controller.navigateToEditProduct(product),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String localId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(localId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
