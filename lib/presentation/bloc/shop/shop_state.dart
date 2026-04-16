import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';

enum ShopStatus { initial, loading, success, failure, checkoutSuccess }

class ShopState extends Equatable {
  final ShopStatus status;
  final List<CartItem> cartItems;
  final String? errorMessage;
  final String? lastScannedBarcode;

  const ShopState({
    this.status = ShopStatus.initial,
    this.cartItems = const [],
    this.errorMessage,
    this.lastScannedBarcode,
  });

  ShopState copyWith({
    ShopStatus? status,
    List<CartItem>? cartItems,
    String? errorMessage,
    String? lastScannedBarcode,
  }) {
    return ShopState(
      status: status ?? this.status,
      cartItems: cartItems ?? this.cartItems,
      errorMessage: errorMessage ?? this.errorMessage,
      lastScannedBarcode: lastScannedBarcode ?? this.lastScannedBarcode,
    );
  }

  double get totalPrice => cartItems.fold(
        0,
        (previousValue, element) => previousValue + element.totalPrice,
      );

  @override
  List<Object?> get props => [status, cartItems, errorMessage, lastScannedBarcode];
}
