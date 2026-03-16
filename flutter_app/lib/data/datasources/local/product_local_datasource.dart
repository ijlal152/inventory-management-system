import 'package:hive/hive.dart';

import '../../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> getUnsyncedProducts();
  Future<ProductModel?> getProductByLocalId(String localId);
  Future<ProductModel?> getProductByBarcode(String barcode);
  Future<void> saveProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String localId);
  Future<void> deleteProductPermanently(String localId);
  Future<void> clearAll();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _boxName = 'products';
  late Box<ProductModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ProductModel>(_boxName);
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    return _box.values.where((p) => !p.isDeleted).toList();
  }

  @override
  Future<List<ProductModel>> getUnsyncedProducts() async {
    return _box.values.where((p) => !p.isSynced).toList();
  }

  @override
  Future<ProductModel?> getProductByLocalId(String localId) async {
    try {
      return _box.values.firstWhere(
        (p) => p.localId == localId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      return _box.values.firstWhere(
        (p) => p.barcode == barcode && !p.isDeleted,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    await _box.put(product.localId, product);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _box.put(product.localId, product);
  }

  @override
  Future<void> deleteProduct(String localId) async {
    final product = await getProductByLocalId(localId);
    if (product != null) {
      final updatedProduct = product.copyWith(
        isDeleted: true,
        isSynced: false,
        syncAction: SyncAction.delete,
        updatedAt: DateTime.now(),
      );
      await _box.put(localId, updatedProduct);
    }
  }

  @override
  Future<void> deleteProductPermanently(String localId) async {
    await _box.delete(localId);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}
