import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> execute(String localId) async {
    return await repository.deleteProduct(localId);
  }
}
