import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartFromScan extends ShopEvent {
  final String barcode;

  const AddToCartFromScan(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class UpdateQuantity extends ShopEvent {
  final String productId;
  final int delta;

  const UpdateQuantity(this.productId, this.delta);

  @override
  List<Object?> get props => [productId, delta];
}

class ClearCart extends ShopEvent {}

class CheckoutCart extends ShopEvent {}
