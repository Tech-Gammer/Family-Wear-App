import 'dart:convert';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowItemProvider with ChangeNotifier {
  List<dynamic> _items = [];

  List<dynamic> get items => _items;

  Future<void> fetchItems() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items";  // Replace with your actual IP
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedItems = json.decode(response.body);

        // Ensure images have full URLs
        _items = fetchedItems.map((item) {
          List<String> imageUrls = (item['item_image'] as List)
              .map((img) => "http://${NetworkConfig().ipAddress}:5000/uploads/$img")  // Full URL
              .toList();
          return {...item, 'item_image': imageUrls};
        }).toList();

        notifyListeners();
      } else {
        throw Exception("Failed to load items");
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }
}
