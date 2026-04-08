import 'package:get_it/get_it.dart';
import 'presentation/cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Home
  
  // Data sources

  // Repository

  // Usecases

  // BLoC / Cubit
  sl.registerFactory(() => ThemeCubit());

  // External
}
