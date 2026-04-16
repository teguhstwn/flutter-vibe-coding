import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../injection.dart';
import '../bloc/shop/shop_bloc.dart';
import '../bloc/shop/shop_event.dart';
import '../bloc/shop/shop_state.dart';
import '../widgets/cart_item_widget.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ShopBloc>(),
      child: const ShopView(),
    );
  }
}

class ShopView extends StatefulWidget {
  const ShopView({super.key});

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  final MobileScannerController scannerController = MobileScannerController();
  DateTime? lastScanTime;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kasir'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                context.read<ShopBloc>().add(ClearCart());
              },
            ),
          ],
        ),
        body: BlocListener<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state.status == ShopStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Terjadi kesalahan')),
              );
            }
            if (state.status == ShopStatus.checkoutSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checkout Berhasil!')),
              );
            }
          },
          child: Column(
            children: [
              // 1. Area Scanner (Selalu Aktif)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: MobileScanner(
                  controller: scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final String? code = barcode.rawValue;
                      if (code != null) {
                        // Implementasi Cooldown 2 detik
                        final now = DateTime.now();
                        if (lastScanTime == null || 
                            now.difference(lastScanTime!).inSeconds >= 2) {
                          lastScanTime = now;
                          context.read<ShopBloc>().add(AddToCartFromScan(code));
                        }
                      }
                    }
                  },
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Divider(),
              ),

              // 2. Daftar List Product Scanned
              Expanded(
                child: BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, state) {
                    if (state.cartItems.isEmpty) {
                      return const Center(
                        child: Text('Belum ada produk yang dipindai'),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return CartItemWidget(
                          item: item,
                          onIncrement: () {
                            context.read<ShopBloc>().add(
                              UpdateQuantity(item.product.id, 1),
                            );
                          },
                          onDecrement: () {
                            context.read<ShopBloc>().add(
                              UpdateQuantity(item.product.id, -1),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // 3. Tombol Checkout dan Total Harga
        bottomNavigationBar: BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Harga',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Rp ${state.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: state.cartItems.isEmpty 
                        ? null 
                        : () {
                            context.read<ShopBloc>().add(CheckoutCart());
                          },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
