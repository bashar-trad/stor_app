import 'dart:convert';
import 'package:stor/pages/shared/models/products_response.dart';
import 'package:http/http.dart' as http;

class Api {
  static const baseUrl = 'dummyjson.com';
 
  static Future<http.Response> get(String path, [Map<String, dynamic>? queryParameters]) async {
    final url = Uri.https(baseUrl, path, queryParameters);
    final response = await http.get(url);
    print('Request Url is: ${url.toString()}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final url = Uri.https(baseUrl, path);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
    print('Request Url is: ${url.toString()}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  static Future<List<String>> fetchCategories() async {
    final response = await get('/products/category-list');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Fetched categories: $data');
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Product>> fetchProducts() async {
    final response = await get('/products');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['products'];
      print('Fetched products: $data');
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Map<String, dynamic>> fetchUserData(String token) async {
    final response = await get('/user/me', {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }
  static Future<Map<String, dynamic>> fetchCards(String userId, String token) async {
    final response = await get('/carts/user$userId', {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
