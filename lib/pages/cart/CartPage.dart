import 'dart:convert';
import 'package:stor/database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stor/services/api.dart';
//import 'package:demostore/services/database_helper.dart';

class CartModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  CartModel() {
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final List<Map<String, dynamic>> maps = await _dbHelper.queryAllItems();
      _count = maps.fold(0, (sum, item) => sum + (item['quantity'] as int));
      notifyListeners();
    } catch (e) {
      print('Error loading count: $e');
    }
  }

  Future<void> _updateItemInDatabase(String productTitle, int quantity, double price) async {
    final List<Map<String, dynamic>> existingItem = await _dbHelper.queryItem(productTitle);
    if (existingItem.isNotEmpty) {
      // Item already exists, update quantity
      final currentQuantity = existingItem.first['quantity'] as int;
      await _dbHelper.updateItem(productTitle, currentQuantity + quantity);
    } else {
      // New item, insert into database
      await _dbHelper.insertItem(productTitle, quantity, price);
    }
    await _loadCount();
  }

  Future<bool> isItemInCart(String productTitle) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.queryItem(productTitle);
    return maps.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getCartItem(String productTitle) async {
    final List<Map<String, dynamic>> maps = await _dbHelper.queryItem(productTitle);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> updateItemQuantity(String productTitle, int quantity) async {
    final List<Map<String, dynamic>> existingItem = await _dbHelper.queryItem(productTitle);
    if (existingItem.isNotEmpty) {
      if (quantity > 0) {
        await _dbHelper.updateItem(productTitle, quantity);
      } else {
        await _dbHelper.deleteItem(productTitle);
      }
      await _loadCount();
    }
  }

  void shared() async {
    final response = await Api.get("user/me");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token'] ?? '');
      await prefs.setString('refreshToken', data['refreshToken'] ?? '');
      await prefs.setString('user', jsonEncode(data));
    }
  }

  void addItem(String productTitle, int quantity, double price) {
    _updateItemInDatabase(productTitle, quantity, price);
  }

  void removeItem(String productTitle) async {
    await _dbHelper.deleteItem(productTitle);
    await _loadCount();
  }
}
