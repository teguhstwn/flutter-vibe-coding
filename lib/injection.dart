import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'data/datasources/product_local_data_source.dart';
import 'data/models/product_model.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/add_product.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Data sources
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(productBox: Hive.box<ProductModel>('products')),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(localDataSource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => DeleteProduct(sl()));

  // BLoC / Cubit
  sl.registerFactory(() => ThemeCubit());

  // ✅ UBAH DARI registerLazySingleton MENJADI registerFactory
  sl.registerFactory(
    () => ProductBloc(
      getProducts: sl(),
      addProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
    ),
  );
}
