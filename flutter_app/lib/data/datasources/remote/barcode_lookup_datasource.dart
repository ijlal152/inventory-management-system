import 'dart:convert';

import 'package:http/http.dart' as http;

/// Data class for barcode lookup result
class BarcodeLookupResult {
  final String barcode;
  final String? productName;
  final double? price;
  final String? description;
  final String? brand;
  final String? category;
  final String? imageUrl;

  BarcodeLookupResult({
    required this.barcode,
    this.productName,
    this.price,
    this.description,
    this.brand,
    this.category,
    this.imageUrl,
  });
}

abstract class BarcodeLookupDataSource {
  Future<BarcodeLookupResult?> lookupBarcode(String barcode);
}

/// Implementation using Open Food Facts API (free, primarily for food products)
/// You can replace this with your own barcode API service
class OpenFoodFactsDataSourceImpl implements BarcodeLookupDataSource {
  final http.Client client;

  OpenFoodFactsDataSourceImpl({required this.client});

  @override
  Future<BarcodeLookupResult?> lookupBarcode(String barcode) async {
    try {
      final response = await client.get(
        Uri.parse(
            'https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if product was found
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];

          return BarcodeLookupResult(
            barcode: barcode,
            productName: product['product_name'] ?? product['product_name_en'],
            description: product['generic_name'] ?? product['ingredients_text'],
            brand: product['brands'],
            category: product['categories'],
            imageUrl: product['image_url'],
            // Open Food Facts doesn't provide pricing, you may need another API for that
            price: null,
          );
        }
      }

      return null; // Product not found
    } catch (e) {
      print('Error looking up barcode: $e');
      return null;
    }
  }
}

/// Alternative: UPCitemdb.com implementation
/// Requires API key from https://www.upcitemdb.com/
class UPCItemDBDataSourceImpl implements BarcodeLookupDataSource {
  final http.Client client;
  final String apiKey;

  UPCItemDBDataSourceImpl({
    required this.client,
    required this.apiKey,
  });

  @override
  Future<BarcodeLookupResult?> lookupBarcode(String barcode) async {
    try {
      final response = await client.get(
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'),
        headers: {
          'Accept': 'application/json',
          'user_key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 'OK' &&
            data['items'] != null &&
            data['items'].isNotEmpty) {
          final item = data['items'][0];

          return BarcodeLookupResult(
            barcode: barcode,
            productName: item['title'],
            description: item['description'],
            brand: item['brand'],
            category: item['category'],
            imageUrl:
                item['images']?.isNotEmpty == true ? item['images'][0] : null,
            // UPCitemdb might have pricing in highest/lowest_recorded_price
            price: item['lowest_recorded_price'] != null
                ? double.tryParse(item['lowest_recorded_price'].toString())
                : null,
          );
        }
      }

      return null;
    } catch (e) {
      print('Error looking up barcode: $e');
      return null;
    }
  }
}

/// Custom implementation for your own backend API
class CustomBackendDataSourceImpl implements BarcodeLookupDataSource {
  final http.Client client;
  final String baseUrl;

  CustomBackendDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<BarcodeLookupResult?> lookupBarcode(String barcode) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/products/lookup/$barcode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        return BarcodeLookupResult(
          barcode: barcode,
          productName: data['name'],
          price: data['price']?.toDouble(),
          description: data['description'],
          brand: data['brand'],
          category: data['category'],
          imageUrl: data['image_url'],
        );
      }

      return null;
    } catch (e) {
      print('Error looking up barcode: $e');
      return null;
    }
  }
}
