import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<void> execute(Product product) async {
    return await repository.updateProduct(product);
  }
}
