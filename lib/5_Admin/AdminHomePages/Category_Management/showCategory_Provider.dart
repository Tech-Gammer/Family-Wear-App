/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../ip_address.dart';

class ShowCategoryProvider with ChangeNotifier {
  List<dynamic> _categories = [];

  List<dynamic> get categories => _categories;

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://${NetworkConfig().ipAddress}:5000/categories'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        _categories = data['categories'];
        notifyListeners();
      }
    } else {
      throw Exception('Failed to load categories');
    }
  }
}*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:family_wear_app/ip_address.dart';

class ShowCategoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> get categories => _categories;

  Future<void> fetchCategories() async {
    final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/get-categories");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _categories = data.map((category) {
        return {
          "id": category["category_id"],
          "name": category["category_name"],
          "imageBase64": category["category_picture"], // Base64 image
        };
      }).toList();
      notifyListeners();
    } else {
      throw Exception("Failed to load categories");
    }
  }
}
