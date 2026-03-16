import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductByBarcodeUseCase {
  final ProductRepository repository;

  GetProductByBarcodeUseCase(this.repository);

  Future<Product?> execute(String barcode) async {
    if (barcode.trim().isEmpty) {
      return null;
    }
    return await repository.getProductByBarcode(barcode.trim());
  }
}
