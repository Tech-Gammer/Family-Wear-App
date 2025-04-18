// import 'package:flutter/material.dart';
//
// class Category {
//   final String name;
//   final String icon;
//
//   Category({required this.name, required this.icon});
// }
//
// class CategoryProvider with ChangeNotifier {
//   final List<Category> _categories = [
//     Category(name: 'Rings', icon: 'asset/ring.jpg'),
//     Category(name: 'Shoes', icon: 'asset/shoes.jpg'),
//     Category(name: 'Watches', icon: 'asset/watch.jpg'),
//     Category(name: 'Wallets', icon: 'asset/wallet.jpg'),
//     Category(name: 'Glasses', icon: 'asset/glasses.jpg'),
//     Category(name: 'Dress', icon: 'asset/dress.jpg'),
//   ];
//
//   List<Category> get categories => _categories;
// }
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../ip_address.dart';

class Category {
  final String name;
  final Uint8List imageBytes;

  Category({required this.name, required this.imageBytes});
}

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String _error = '';

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://${NetworkConfig().ipAddress}:5000/categories'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _categories = data.map((category) {
          final imageBytes = _decodeImage(category['category_picture']);
          return Category(
            name: category['category_name'],
            imageBytes: imageBytes ?? Uint8List(0), // Handle null images
          );
        }).toList();
        _error = '';
      } else {
        _error = 'Failed to load categories: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching categories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      if (kDebugMode) print("Image decode error: $e");
      return null;
    }
  }
}