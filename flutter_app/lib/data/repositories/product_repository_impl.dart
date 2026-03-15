import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../models/product_model.dart' as model;
import '../models/product_model.dart' show ProductModel;

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Product>> getAllProducts() async {
    final models = await localDataSource.getAllProducts();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product?> getProductById(String localId) async {
    final model = await localDataSource.getProductByLocalId(localId);
    return model?.toEntity();
  }

  @override
  Future<void> createProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    await localDataSource.saveProduct(model);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final productModel = ProductModel.fromEntity(product).copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
      syncAction: model.SyncAction.update,
    );
    await localDataSource.updateProduct(productModel);
  }

  @override
  Future<void> deleteProduct(String localId) async {
    await localDataSource.deleteProduct(localId);
  }

  @override
  Future<void> syncProducts() async {
    final unsyncedProducts = await localDataSource.getUnsyncedProducts();

    for (var product in unsyncedProducts) {
      try {
        switch (product.syncAction) {
          case model.SyncAction.create:
            final synced = await remoteDataSource.createProduct(product);
            await localDataSource.updateProduct(synced);
            break;

          case model.SyncAction.update:
            if (product.serverId != null) {
              final synced = await remoteDataSource.updateProduct(
                product.serverId!,
                product,
              );
              await localDataSource.updateProduct(synced);
            }
            break;

          case model.SyncAction.delete:
            if (product.serverId != null) {
              await remoteDataSource.deleteProduct(product.serverId!);
            }
            await localDataSource.deleteProductPermanently(product.localId);
            break;
        }
      } catch (e) {
        // Log error, will retry in next sync
        print('Sync failed for product ${product.localId}: $e');
      }
    }
  }
}
