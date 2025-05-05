import 'dart:convert';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Category {
  final dynamic id;
  final String name;

  Category({required this.id, required this.name});
}

class Unit {
  final dynamic id;
  final String name;
  Unit({required this.id, required this.name});
}

class ShowItemProvider with ChangeNotifier {
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  List<Unit> _units = [];  // Add a list for units
  List<Category> _categories = [];
  Category? _selectedCategory;
  String _searchQuery = '';
  int? _selectedCategoryId;

  List<dynamic> get items => _filteredItems;
  List<Category> get categories => _categories;
  List<Unit> get units => _units; // Expose the list of units
  Category? get selectedCategory => _selectedCategory;

  void setSearchQuery(String query) {
    _searchQuery = query;
    applyFilter();
  }

  void setSelectedCategoryforsearch(int? categoryId) {
    _selectedCategoryId = categoryId;
    applyFilter();
  }

  Future<void> fetchItems({bool activeOnly = true, String? search, int? categoryId}) async {
    // final url = "http://${NetworkConfig().ipAddress}:5000/items?active=${activeOnly}";
    final url = Uri.parse(
        'http://${NetworkConfig().ipAddress}:5000/items?active=$activeOnly'
            '${search != null ? '&search=$search' : ''}'
            '${categoryId != null ? '&category=$categoryId' : ''}'
    );
    try {
      final response = await http.get(url);
      // final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedItems = json.decode(response.body);
        _items = fetchedItems.map<Map<String, dynamic>>((item) {
          final typedItem = Map<String, dynamic>.from(item);
          List<String> imageUrls = (typedItem['item_image'] as List)
              .map((img) => "http://${NetworkConfig().ipAddress}:5000/uploads/$img")
              .toList();
          typedItem['item_image'] = imageUrls;
          return typedItem;
        }).toList();
        applyFilter();
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  Future<void> fetchUnits() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items/units"; // Adjust API URL for units
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _units = data.map((json) => Unit(
          id: json['unit_id'],
          name: json['unit_name'],
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching units: $e");
    }
  }

  Future<void> fetchCategories() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items/categories";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _categories = data
            .map((json) => Category(
          id: json['category_id'],
          name: json['category_name'],
        ))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> deleteItem(dynamic itemId) async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items/$itemId";

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        _items.removeWhere((item) => item['item_id'] == itemId);
        applyFilter();
      } else {
        // Parse error message from server response
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Deletion failed';
        throw Exception(errorMessage); // Throw meaningful error
      }
    } catch (e) {
      print("Error deleting item: $e");
      throw e; // Re-throw to handle in UI
    }
  }

  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    applyFilter();
  }

  void applyFilter({bool showInactiveOnly = false}) {
    List<dynamic> filtered = _items;

    // First apply category filter
    if (_selectedCategoryId  != null) {
      filtered = filtered.where((item) => item['category_id'] == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) =>
          item['item_name'].toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    // Then apply inactive filter
    if (showInactiveOnly) {
      filtered = filtered.where((item) => item['is_active'] == false || item['is_active'] == 0).toList();
    }

    _filteredItems = filtered;
    notifyListeners();
  }

  Future<void> updateItemStatus(dynamic itemId, bool isActive) async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items/$itemId/status";
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_active': isActive}),
      );
      if (response.statusCode == 200) {
        await fetchItems(); // Refresh the list
      } else {
        throw Exception('Failed to update item status');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }


}
