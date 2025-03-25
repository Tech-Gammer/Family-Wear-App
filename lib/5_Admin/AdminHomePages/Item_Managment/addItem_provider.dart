/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItemProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  int _currentIndex = 0;

  String? _selectedCategory;
  List<String> _categories = ["Electronics", "Clothing", "Groceries", "Home Decor"];

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController taxPercentController = TextEditingController();
  final TextEditingController taxPriceController = TextEditingController();
  final TextEditingController netPriceController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();

  List<File> get images => _images;
  int get currentIndex => _currentIndex;
  String? get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;

  Future<void> pickImages() async {
    if (_images.length >= 8) return;

    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      _images.addAll(selectedImages.map((e) => File(e.path)));
      if (_images.length > 8) {
        _images = _images.sublist(0, 8);
      }
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    if (_currentIndex >= _images.length && _currentIndex > 0) {
      _currentIndex--;
    }
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addCategory(String newCategory) {
    _categories.add(newCategory);
    _selectedCategory = newCategory;
    notifyListeners();
  }
}
*/

import 'dart:io';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AddItemProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  String? _selectedCategory;

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController taxPercentController = TextEditingController();
  final TextEditingController taxPriceController = TextEditingController();
  final TextEditingController netPriceController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();

  List<File> get images => _images;
  String? get selectedCategory => _selectedCategory;

  Future<void> pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      _images.addAll(selectedImages.map((e) => File(e.path)));
      if (_images.length > 8) {
        _images = _images.sublist(0, 8);
      }
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  Future<void> uploadItem(BuildContext context) async {
    if (itemNameController.text.isEmpty || salePriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    var uri = Uri.parse("http://${NetworkConfig().ipAddress}:5000/addItem");
    var request = http.MultipartRequest("POST", uri);

    //request.fields["category_id"] = "1";
    //request.fields["unit_id"] = "1";
    request.fields["item_name"] = itemNameController.text;
    request.fields["item_description"] = descriptionController.text;
    request.fields["purchase_price"] = purchasePriceController.text;
    request.fields["sale_price"] = salePriceController.text;
    request.fields["tax_in_percent"] = taxPercentController.text;
    request.fields["tax_in_amount"] = taxPriceController.text;
    request.fields["net_price"] = netPriceController.text;
    request.fields["minimum_qty"] = minQuantityController.text;

    for (var image in _images) {
      request.files.add(await http.MultipartFile.fromPath('item_images', image.path));
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item added successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to add item.")));
    }
  }
}
