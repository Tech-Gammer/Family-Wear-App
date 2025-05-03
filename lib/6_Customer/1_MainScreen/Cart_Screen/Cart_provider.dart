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
    int get itemCount => cartItems.length;
    double get subtotal => cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    bool _isLoading = false;
    List<CartItem> get cartItems => _cartItems;
    bool get isLoading => _isLoading;

    Future<void> fetchCartItems({required String userId}) async {
      _isLoading = true;
      _userId = userId;  // <--- ADD THIS LINE
      notifyListeners();

      try {
        final response = await http.get(
          Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/$userId'),
        );

        if (response.statusCode == 200) {
          final List<dynamic> responseData = json.decode(response.body);
          _cartItems = responseData.map((item) => CartItem.fromJson(item)).toList();
        } else {
          throw Exception('Failed to load cart items');
        }
      } catch (e) {
        print('Error fetching cart items: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

    Future<bool> addToCart(String userId, String itemId) async {
      try {
        final response = await http.post(
          Uri.parse('http://${NetworkConfig().ipAddress}:5000/add-to-cart'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'user_id': userId, 'item_id': itemId}),
        );

        if (response.statusCode == 200) {
          await fetchCartItems(userId: userId);
          return true;
        }
        return false;
      } catch (e) {
        print('Error adding to cart: $e');
        return false;
      }
    }

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

    // Future<void> updateQuantity(String itemId, int change) async {
    //   final index = _cartItems.indexWhere((item) => item.itemId == itemId);
    //   if (index == -1) return;
    //
    //   // Save old value for rollback
    //   final oldQuantity = _cartItems[index].quantity;
    //
    //   // Optimistic update: Immediately change UI
    //   _cartItems[index].quantity += change;
    //   notifyListeners();
    //
    //   try {
    //     final response = await http.put(
    //       Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/update-quantity'),
    //       body: jsonEncode({
    //         'user_id': _userId,
    //         'item_id': itemId,
    //         'change': change,
    //       }),
    //     );
    //
    //     if (response.statusCode != 200) {
    //       // Rollback on error
    //       _cartItems[index].quantity = oldQuantity;
    //       notifyListeners();
    //     }
    //   } catch (e) {
    //     _cartItems[index].quantity = oldQuantity;
    //     notifyListeners();
    //   }
    // }
    Future<void> updateQuantity(String itemId, int change) async {
      final index = _cartItems.indexWhere((item) => item.itemId == itemId);
      if (index == -1) return;

      final oldQuantity = _cartItems[index].quantity;

      _cartItems[index].quantity += change;
      notifyListeners();

      try {
        final response = await http.put(
          Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/update-quantity'),
          headers: {'Content-Type': 'application/json'}, // <--- Add this header
          body: jsonEncode({
            'user_id': _userId,
            'item_id': itemId,
            'change': change,
          }),
        );

        print('Update Quantity Response: ${response.statusCode}');
        print('Update Quantity Body: ${response.body}');

        if (response.statusCode != 200) {
          _cartItems[index].quantity = oldQuantity;
          notifyListeners();
        }
      } catch (e) {
        print('Update Quantity Error: $e');
        _cartItems[index].quantity = oldQuantity;
        notifyListeners();
      }
    }


    // Future<void> removeFromCart(String itemId) async {
    //   final index = _cartItems.indexWhere((item) => item.itemId == itemId);
    //   if (index == -1) return;
    //
    //   // Optimistic removal
    //   final removedItem = _cartItems.removeAt(index);
    //   notifyListeners();
    //
    //   try {
    //     final response = await http.delete(
    //       Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/remove-item'),
    //       body: jsonEncode({'user_id': _userId, 'item_id': itemId}),
    //     );
    //
    //     if (response.statusCode != 200) {
    //       // Rollback on error
    //       _cartItems.insert(index, removedItem);
    //       notifyListeners();
    //     }
    //   } catch (e) {
    //     _cartItems.insert(index, removedItem);
    //     notifyListeners();
    //   }
    // }
    Future<void> removeFromCart(String itemId) async {
      final index = _cartItems.indexWhere((item) => item.itemId == itemId);
      if (index == -1) return;

      final removedItem = _cartItems.removeAt(index);
      notifyListeners();

      try {
        final response = await http.delete(
          Uri.parse('http://${NetworkConfig().ipAddress}:5000/cart/remove-item'),
          headers: {'Content-Type': 'application/json'}, // <--- Add this
          body: jsonEncode({'user_id': _userId, 'item_id': itemId}),
        );

        print('Remove Item Response: ${response.statusCode}');
        print('Remove Item Body: ${response.body}');

        if (response.statusCode != 200) {
          _cartItems.insert(index, removedItem);
          notifyListeners();
        }
      } catch (e) {
        print('Remove Item Error: $e');
        _cartItems.insert(index, removedItem);
        notifyListeners();
      }
    }


    Future<void> clearCart() async {
      // You might want to implement a batch delete API for this
      _cartItems.removeWhere((item) => item.userId == _userId);
      notifyListeners();
    }


  }