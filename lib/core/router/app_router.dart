import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/billing_page.dart';
import '../../presentation/pages/product_page.dart';
import '../../presentation/pages/add_product_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/shop_page.dart';
import '../../domain/entities/product.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/billing',
      builder: (BuildContext context, GoRouterState state) {
        return const BillingPage();
      },
    ),
    GoRoute(
      path: '/product',
      builder: (BuildContext context, GoRouterState state) {
        return const ProductPage();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsPage();
      },
    ),
    GoRoute(
      path: '/shop',
      builder: (BuildContext context, GoRouterState state) {
        return const ShopPage();
      },
    ),
    GoRoute(
      path: '/add-product',
      builder: (BuildContext context, GoRouterState state) {
        final product = state.extra as Product?;
        return AddProductPage(product: product);
      },
    ),
  ],
);
