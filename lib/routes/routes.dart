import 'package:stor/pages/auth/AccountPage.dart';
import 'package:stor/pages/orders/OrdersPage.dart';
import 'package:stor/pages/products/ProductsPage.dart';
import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/update_user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Routes {
  // final Product product;
  // Routes(this.product);
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String updateUser = '/updateUser';
  static const String account = '/account';
  static const String products = '/Products';
  static const String productDetails = '/ProductDetails';
  static const String ordersPage='/order';
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      login: (context) => LoginPage(),
      register: (context) => const RegisterPage(),
      updateUser: (context) => const UpdateUserPage(),
      account: (context) => const AccountPage(),
      products: (context) => const ProductsPage(),
      ordersPage:(context) => const OrdersPage(),
      // ProductDetails: (context) => ProductDetailsPage(product:product),
    };
  }

  static Future<void> checkLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, login);
    } else {
      Navigator.pushReplacementNamed(context, home);
    }
  }
}
