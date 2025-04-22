import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../../ip_address.dart';

class CartItem {
  final String userId; // Add user ID association
  final String itemId;
  final String title;
  final String category;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.userId, // Add this
    required this.itemId,
    required this.title,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  // Add fromJson constructor for API responses
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      userId: json['user_id'].toString(),
      itemId: json['item_id'].toString(),
      title: json['title'] ?? 'Unknown Item',
      category: json['category'] ?? 'Unknown Category',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/150',
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartProvider extends ChangeNotifier {
  String? _userId;
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems.where((item) => item.userId == _userId).toList();

  int get itemCount => cartItems.length;

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  //
  // void initialize(String userId) {
  //   _userId = userId;
  //   _loadCartItems();
  // }
  Future<void> initialize(String userId) async {
    _userId = userId;
    await _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    if (_userId == null) return;

    try {
      final response = await http.get(Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/$_userId'));
      if (response.statusCode == 200) {
        _cartItems = (jsonDecode(response.body) as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  Future<void> addToCart(CartItem item) async {
    try {
      final response = await http.post(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/add-to-cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'item_id': item.itemId,
        }),
      );

      if (response.statusCode == 200) {
        // Check if item already exists in local cart
        final existingIndex = _cartItems.indexWhere(
                (i) => i.itemId == item.itemId && i.userId == _userId
        );

        if (existingIndex != -1) {
          _cartItems[existingIndex].quantity++;
        } else {
          _cartItems.add(item);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/remove-item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'item_id': itemId,
        }),
      );

      if (response.statusCode == 200) {
        _cartItems.removeWhere((item) => item.itemId == itemId && item.userId == _userId);
        notifyListeners();
      }
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> updateQuantity(String itemId, int change) async {
    try {
      final response = await http.put(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/update-quantity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'item_id': itemId,
          'change': change,
        }),
      );

      if (response.statusCode == 200) {
        final index = _cartItems.indexWhere(
                (item) => item.itemId == itemId && item.userId == _userId
        );

        if (index != -1) {
          _cartItems[index].quantity = (_cartItems[index].quantity + change).clamp(1, 99);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> clearCart() async {
    // You might want to implement a batch delete API for this
    _cartItems.removeWhere((item) => item.userId == _userId);
    notifyListeners();
  }
}