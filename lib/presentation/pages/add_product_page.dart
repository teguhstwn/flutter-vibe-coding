import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../bloc/product/product_bloc.dart';
import '../../../domain/entities/product.dart';
import '../../../injection.dart';

class AddProductPage extends StatefulWidget {
  final Product? product;
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.product!.name;
      _barcodeController.text = widget.product!.barcodeValue;
      _priceController.text = widget.product!.price.toStringAsFixed(0);
      _stockController.text = widget.product!.stock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _scanBarcode() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BarcodeScannerSheet(),
    );

    if (result != null && mounted) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: const Uuid().v4(),
        name: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        barcodeValue: _barcodeController.text,
      );

      context.read<ProductBloc>().add(AddProductEvent(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProductBloc>(),
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductAddSuccess || state is ProductUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(isEdit
                      ? 'Produk berhasil diperbarui'
                      : 'Produk berhasil ditambahkan')),
            );
            context.pop();
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _barcodeController,
                          decoration: const InputDecoration(
                            labelText: 'Barcode',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Barcode wajib diisi'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _scanBarcode,
                        icon: const Icon(Icons.qr_code_scanner),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Harga wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Stok wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),
                  Builder(builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final product = Product(
                            id: isEdit ? widget.product!.id : const Uuid().v4(),
                            name: _nameController.text,
                            price: double.parse(_priceController.text),
                            stock: int.parse(_stockController.text),
                            barcodeValue: _barcodeController.text,
                            isDeleted: isEdit ? widget.product!.isDeleted : false,
                          );

                          if (isEdit) {
                            context
                                .read<ProductBloc>()
                                .add(UpdateProductEvent(product));
                          } else {
                            context
                                .read<ProductBloc>()
                                .add(AddProductEvent(product));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isEdit ? 'Update Produk' : 'Simpan Produk'),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BarcodeScannerSheet extends StatefulWidget {
  const BarcodeScannerSheet({super.key});

  @override
  State<BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<BarcodeScannerSheet> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Barcode',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  if (isScanned) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      isScanned = true;
                      Navigator.pop(context, barcode.rawValue);
                      break;
                    }
                  }
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Arahkan kamera ke barcode produk',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
