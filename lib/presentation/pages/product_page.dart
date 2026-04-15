import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/product/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../injection.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider berada di paling atas
    return BlocProvider(
      create: (context) => sl<ProductBloc>()..add(LoadProductsEvent()),
      child: const ProductView(),
    );
  }
}

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
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
          title: const Text('Product'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Column(
          children: [
            /// 🔍 SEARCH FIELD
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    // ✅ KRUSIAL: Cek mounted agar tidak error saat context sudah hilang
                    if (mounted) {
                      context.read<ProductBloc>().add(SearchProductEvent(value));
                    }
                  });
                },
              ),
            ),

            /// 📦 LIST / STATE
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductEmpty) {
                    return _buildEmptyState();
                  }
                  if (state is ProductNoResults) {
                    return const Center(child: Text('Produk tidak ditemukan.'));
                  }
                  if (state is ProductLoaded) {
                    return _buildList(state.products);
                  }
                  if (state is ProductError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.push('/add-product');
            if (mounted) {
              context.read<ProductBloc>().add(LoadProductsEvent());
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Belum ada produk.', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: ListTile(
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    await context.push('/add-product', extra: product);
                    if (mounted) context.read<ProductBloc>().add(LoadProductsEvent());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, product),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    final bloc = context.read<ProductBloc>(); // Ambil referensi sebelum dialog muncul
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text('Hapus?'),
        content: Text('Hapus ${product.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dContext), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              bloc.add(DeleteProductEvent(product.id));
              Navigator.pop(dContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}