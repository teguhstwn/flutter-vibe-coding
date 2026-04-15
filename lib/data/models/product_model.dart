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
  @HiveField(5)
  final bool isDeleted;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.barcodeValue,
    this.isDeleted = false,
  }) : super(
          id: id,
          name: name,
          price: price,
          stock: stock,
          barcodeValue: barcodeValue,
          isDeleted: isDeleted,
        );

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? barcodeValue,
    bool? isDeleted,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      barcodeValue: barcodeValue ?? this.barcodeValue,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      barcodeValue: product.barcodeValue,
      isDeleted: product.isDeleted,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
      stock: stock,
      barcodeValue: barcodeValue,
      isDeleted: isDeleted,
    );
  }
}
