import '../repositories/product_repository.dart';

class SyncProductsUseCase {
  final ProductRepository repository;

  SyncProductsUseCase(this.repository);

  Future<void> execute() async {
    return await repository.syncProducts();
  }
}
