import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getProducts() async {
    final models = await localDataSource.getProducts();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    await localDataSource.addProduct(model);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    await localDataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await localDataSource.deleteProduct(id);
  }
}
