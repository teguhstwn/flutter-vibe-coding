import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String barcodeValue;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.barcodeValue,
  });

  @override
  List<Object?> get props => [id, name, price, stock, barcodeValue];
}
