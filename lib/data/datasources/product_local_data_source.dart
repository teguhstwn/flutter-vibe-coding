import 'package:hive/hive.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts();
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box<ProductModel> productBox;

  ProductLocalDataSourceImpl({required this.productBox});

  @override
  Future<List<ProductModel>> getProducts() async {
    return productBox.values.where((p) => !p.isDeleted).toList();
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await productBox.put(product.id, product);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await productBox.put(product.id, product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    final product = productBox.get(id);
    if (product != null) {
      final updatedProduct = product.copyWith(isDeleted: true);
      await productBox.put(id, updatedProduct);
    }
  }
}
