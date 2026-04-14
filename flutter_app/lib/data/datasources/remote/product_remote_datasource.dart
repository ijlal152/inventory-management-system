import 'package:dio/dio.dart';

import '../../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductModel> createProduct(ProductModel product);
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProduct(String serverId);
  Future<ProductModel> updateProduct(String serverId, ProductModel product);
  Future<void> deleteProduct(String serverId);
  Future<Map<String, dynamic>> bulkSync(List<Map<String, dynamic>> products);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await dio.post(
        '/products',
        data: product.toApiJson(),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'];
        return product.copyWith(
          serverId: data['id'].toString(),
          isSynced: true,
          lastSyncedAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to create product: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to create product: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await dio.get('/products');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load products: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<ProductModel> getProduct(String serverId) async {
    try {
      final response = await dio.get('/products/$serverId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ProductModel.fromJson(data);
      } else {
        throw Exception('Failed to load product');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to load product: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<ProductModel> updateProduct(
      String serverId, ProductModel product) async {
    try {
      final response = await dio.put(
        '/products/$serverId',
        data: product.toApiJson(),
      );

      if (response.statusCode == 200) {
        return product.copyWith(
          isSynced: true,
          lastSyncedAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to update product');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to update product: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> deleteProduct(String serverId) async {
    try {
      final response = await dio.delete('/products/$serverId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete product');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to delete product: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> bulkSync(
      List<Map<String, dynamic>> products) async {
    try {
      final response = await dio.post(
        '/products/sync',
        data: {'products': products},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to sync products');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to sync products: ${e.response?.data ?? e.message}');
    }
  }
}
