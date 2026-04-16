import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/usecases/get_product_by_barcode.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetProductByBarcode getProductByBarcode;

  ShopBloc({required this.getProductByBarcode}) : super(const ShopState()) {
    on<AddToCartFromScan>(_onAddToCartFromScan);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
    on<CheckoutCart>(_onCheckoutCart);
  }

  Future<void> _onAddToCartFromScan(
      AddToCartFromScan event, Emitter<ShopState> emit) async {
    // Avoid double scanning the same barcode immediately
    if (state.lastScannedBarcode == event.barcode && 
        state.status == ShopStatus.loading) return;

    // Optional: Cooldown for the same barcode to prevent "spam"
    // (Handled by checking lastScannedBarcode and time offset if needed, 
    // but here we focus on core requirement)

    emit(state.copyWith(status: ShopStatus.loading, lastScannedBarcode: event.barcode));

    final product = await getProductByBarcode.execute(event.barcode);

    if (product == null) {
      emit(state.copyWith(
        status: ShopStatus.failure,
        errorMessage: 'Produk tidak ditemukan',
        lastScannedBarcode: null,
      ));
      return;
    }

    final cartItems = List<CartItem>.from(state.cartItems);
    final index = cartItems.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    } else {
      cartItems.add(CartItem(product: product, quantity: 1));
    }

    emit(state.copyWith(
      status: ShopStatus.success,
      cartItems: cartItems,
      lastScannedBarcode: event.barcode,
    ));
    
    // Reset status to success to allow next scan behavior properly
    // but keep cartItems. Status success can trigger feedback in UI if needed.
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<ShopState> emit) {
    final cartItems = List<CartItem>.from(state.cartItems);
    final index = cartItems.indexWhere((item) => item.product.id == event.productId);

    if (index != -1) {
      final newQuantity = cartItems[index].quantity + event.delta;
      if (newQuantity > 0) {
        cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
      } else {
        cartItems.removeAt(index);
      }
      emit(state.copyWith(cartItems: cartItems, status: ShopStatus.success));
    }
  }

  void _onClearCart(ClearCart event, Emitter<ShopState> emit) {
    emit(const ShopState());
  }

  void _onCheckoutCart(CheckoutCart event, Emitter<ShopState> emit) {
    if (state.cartItems.isEmpty) return;
    
    // Implement checkout logic here (e.g. save to DB)
    // For now, just success
    emit(state.copyWith(status: ShopStatus.checkoutSuccess));
    // Reset cart after success if needed, or keep it.
    // Based on requirement: reset after successful checkout.
    emit(const ShopState(status: ShopStatus.initial));
  }
}
