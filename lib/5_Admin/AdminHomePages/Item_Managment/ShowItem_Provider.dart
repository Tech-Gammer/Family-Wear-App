import 'dart:convert';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// first perfectly working code
/*
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
*/

// second chips id filter code
/*
class ShowItemProvider with ChangeNotifier {
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  List<dynamic> _categories = [];
  dynamic _selectedCategory;

  List<dynamic> get items => _filteredItems;
  List<dynamic> get categories => _categories;
  dynamic get selectedCategory => _selectedCategory;

  Future<void> fetchItems() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedItems = json.decode(response.body);
        _items = fetchedItems.map((item) {
          List<String> imageUrls = (item['item_image'] as List)
              .map((img) => "http://${NetworkConfig().ipAddress}:5000/uploads/$img")
              .toList();
          return {...item, 'item_image': imageUrls};
        }).toList();
        applyFilter(); // apply filter if any
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  Future<void> fetchCategories() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items/categories";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _categories = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  void setSelectedCategory(dynamic categoryId) {
    _selectedCategory = categoryId;
    applyFilter();
  }

  void applyFilter() {
    if (_selectedCategory == null) {
      _filteredItems = _items;
    } else {
      _filteredItems = _items
          .where((item) => item['category_id'] == _selectedCategory)
          .toList();
    }
    notifyListeners();
  }
}
*/

//third chips name filter code
/*class Category {
  final dynamic id;
  final String name;

  Category({required this.id, required this.name});
}

class ShowItemProvider with ChangeNotifier {
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  //List<Category> _categories = [];
  Category? _selectedCategory;

  List<dynamic> get items => _filteredItems;
  //List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;

  Future<void> fetchItems() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedItems = json.decode(response.body);
        _items = fetchedItems.map((item) {
          List<String> imageUrls = (item['item_image'] as List)
              .map((img) => "http://${NetworkConfig().ipAddress}:5000/uploads/$img")
              .toList();
          return {...item, 'item_image': imageUrls};
        }).toList();

        applyFilter();
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  Future<void> fetchCategories() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/categorie"; // backend route to get all categories
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _categories = json.decode(response.body);
        notifyListeners();
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }


/*
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
*/

  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    applyFilter();
  }

  void applyFilter() {
    if (_selectedCategory == null) {
      _filteredItems = _items;
    } else {
      final selectedId = int.tryParse(_selectedCategory!.id.toString());
      _filteredItems = _items.where((item) {
        final itemCategoryId = (item['category_id'] as num).toInt();
        return itemCategoryId == selectedId;
      }).toList();
    }
    notifyListeners();
  }

}*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:family_wear_app/ip_address.dart';

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

  List<dynamic> get items => _filteredItems;
  List<Category> get categories => _categories;
  List<Unit> get units => _units; // Expose the list of units
  Category? get selectedCategory => _selectedCategory;

  Future<void> fetchItems() async {
    final url = "http://${NetworkConfig().ipAddress}:5000/items";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedItems = json.decode(response.body);
        _items = fetchedItems.map((item) {
          List<String> imageUrls = (item['item_image'] as List)
              .map((img) => "http://${NetworkConfig().ipAddress}:5000/uploads/$img")
              .toList();
          return {...item, 'item_image': imageUrls};
        }).toList();

        applyFilter();
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }


  // Fetch units just like you fetch categories
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
        applyFilter(); // Refresh filtered list
      } else {
        print("Delete failed: ${response.body}");
      }
    } catch (e) {
      print("Error deleting item: $e");
    }
  }

  void setSelectedCategory(Category? category) {
    _selectedCategory = category;
    applyFilter();
  }

  void applyFilter() {
    if (_selectedCategory == null) {
      _filteredItems = _items;
    } else {
      _filteredItems = _items
          .where((item) => item['category_id'] == _selectedCategory!.id)
          .toList();
    }
    notifyListeners();
  }
}
