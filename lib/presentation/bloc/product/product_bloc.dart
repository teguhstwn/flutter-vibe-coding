import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_products.dart';
import '../../../domain/usecases/add_product.dart';
import '../../../domain/usecases/update_product.dart';
import '../../../domain/usecases/delete_product.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProductsEvent extends ProductEvent {}

class AddProductEvent extends ProductEvent {
  final Product product;
  const AddProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateProductEvent extends ProductEvent {
  final Product product;
  const UpdateProductEvent(this.product);

  @override
  List<Object> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  const DeleteProductEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SearchProductEvent extends ProductEvent {
  final String query;
  const SearchProductEvent(this.query);

  @override
  List<Object> get props => [query];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final String query;
  const ProductLoaded(this.products, {this.query = ''});

  @override
  List<Object> get props => [products, query];
}

class ProductEmpty extends ProductState {}

class ProductNoResults extends ProductState {
  final String query;
  const ProductNoResults(this.query);

  @override
  List<Object> get props => [query];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductAddSuccess extends ProductState {}

class ProductUpdateSuccess extends ProductState {}

class ProductDeleteSuccess extends ProductState {}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  List<Product> _allProducts = [];
  String _currentQuery = '';

  ProductBloc({
    required this.getProducts,
    required this.addProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<SearchProductEvent>(_onSearchProduct);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (_allProducts.isEmpty) {
      emit(ProductLoading());
    }
    try {
      final products = await getProducts.execute();
      _allProducts = products;
      _applyFilter(emit);
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await addProduct.execute(event.product);
      emit(ProductAddSuccess());
      add(LoadProductsEvent());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await updateProduct.execute(event.product);
      emit(ProductUpdateSuccess());
      add(LoadProductsEvent());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await deleteProduct.execute(event.id);
      emit(ProductDeleteSuccess());
      add(LoadProductsEvent());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onSearchProduct(
    SearchProductEvent event,
    Emitter<ProductState> emit,
  ) {
    print('SEARCH: ${event.query}');
    print('TOTAL DATA: ${_allProducts.length}');
    _currentQuery = event.query;
    _applyFilter(emit);
  }

  void _applyFilter(Emitter<ProductState> emit) {
    if (_allProducts.isEmpty) {
      emit(ProductEmpty());
      return;
    }

    if (_currentQuery.isEmpty) {
      emit(ProductLoaded(_allProducts, query: ''));
    } else {
      final filteredProducts = _allProducts
          .where((product) =>
              product.name.toLowerCase().contains(_currentQuery.toLowerCase()))
          .toList();
      if (filteredProducts.isEmpty) {
        emit(ProductNoResults(_currentQuery));
      } else {
        emit(ProductLoaded(filteredProducts, query: _currentQuery));
      }
    }
  }
}
