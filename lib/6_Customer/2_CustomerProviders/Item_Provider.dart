import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../ip_address.dart';

class Item {
  final String image;
  final String name;
  final String description;
  final String price;
  final String soldItem;
  final double rating;
  bool isFavorite;

  Item({required this.image, required this.name, required this.description, required this.price, required this.soldItem, this.rating = 0.0 , this.isFavorite = false});
}

class ItemProvider with ChangeNotifier {
  Set<String> favoriteItems = {};
  final String apiUrl = "http://${NetworkConfig().ipAddress}:5000";

  Future<void> toggleFavorite(String itemId, String userId) async {
    try {
      final isCurrentlyFavorite = favoriteItems.contains(itemId);
      final url = isCurrentlyFavorite
          ? '$apiUrl/remove-from-wishlist'
          : '$apiUrl/add-to-wishlist';

      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'user_id': userId,
          'item_id': itemId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (isCurrentlyFavorite) {
          favoriteItems.remove(itemId);
        } else {
          favoriteItems.add(itemId);
        }
        notifyListeners();
      }
    } catch (error) {
      print('Wishlist error: $error');
    }
  }

  Future<void> loadFavorites(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/get-wishlist?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        favoriteItems = Set<String>.from(data['wishlist']);
        notifyListeners();
      }
    } catch (error) {
      print('Error loading favorites: $error');
    }
  }

}
