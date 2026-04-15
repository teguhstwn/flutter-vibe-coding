import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<void> execute(String id) async {
    return await repository.deleteProduct(id);
  }
}
