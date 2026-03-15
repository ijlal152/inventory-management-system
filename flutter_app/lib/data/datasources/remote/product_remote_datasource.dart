import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
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
  final http.Client client;

  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toApiJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return product.copyWith(
        serverId: data['id'].toString(),
        isSynced: true,
        lastSyncedAt: DateTime.now(),
      );
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/products'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<ProductModel> getProduct(String serverId) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/products/$serverId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return ProductModel.fromJson(data);
    } else {
      throw Exception('Failed to load product');
    }
  }

  @override
  Future<ProductModel> updateProduct(
      String serverId, ProductModel product) async {
    final response = await client.put(
      Uri.parse('${ApiConstants.baseUrl}/products/$serverId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toApiJson()),
    );

    if (response.statusCode == 200) {
      return product.copyWith(
        isSynced: true,
        lastSyncedAt: DateTime.now(),
      );
    } else {
      throw Exception('Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(String serverId) async {
    final response = await client.delete(
      Uri.parse('${ApiConstants.baseUrl}/products/$serverId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  @override
  Future<Map<String, dynamic>> bulkSync(
      List<Map<String, dynamic>> products) async {
    final response = await client.post(
      Uri.parse('${ApiConstants.baseUrl}/products/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'products': products}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sync products');
    }
  }
}
