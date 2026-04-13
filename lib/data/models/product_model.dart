import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double price;
  @HiveField(3)
  final int stock;
  @HiveField(4)
  final String barcodeValue;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.barcodeValue,
  }) : super(
          id: id,
          name: name,
          price: price,
          stock: stock,
          barcodeValue: barcodeValue,
        );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      barcodeValue: product.barcodeValue,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
      stock: stock,
      barcodeValue: barcodeValue,
    );
  }
}
