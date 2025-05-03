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
  List<Map<String, dynamic>> _categories = []; // Stores categories

  String? _selectedUnit;
  List<Map<String, dynamic>> _quantitUnit = []; // Stores categories


  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController taxPercentController = TextEditingController();
  final TextEditingController taxPriceController = TextEditingController();
  final TextEditingController netPriceController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();
  //final TextEditingController minQuantityController = TextEditingController();

  List<File> get images => _images;
  String? get selectedCategory => _selectedCategory;
  List<Map<String, dynamic>> get categories => _categories;

  String? get selectedUnit => _selectedUnit;
  List<Map<String, dynamic>> get quantityUnit => _quantitUnit;

  // Fetch categories from backend
  Future<void> fetchCategories() async {
    var url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/categories"); // Change if needed
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _categories = data.map((category) => {
          "id": category["category_id"],
          "name": category["category_name"]
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> fetchUnits() async {
    var url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/get-units");

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _quantitUnit = data.map((unit) => {
          "id": unit["unit_id"],
          "name": unit["unit_name"]
        }).toList();
        notifyListeners();
      } else {
        print("Failed to fetch units. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching units: $e");
    }
  }

  void setUnit(String? unit) {
    if (unit == null) return;
    _selectedUnit = unit;
    notifyListeners();
  }

  // Select Category
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }


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
    if (itemNameController.text.isEmpty || salePriceController.text.isEmpty || _selectedCategory == null || _selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    var uri = Uri.parse("http://${NetworkConfig().ipAddress}:5000/addItem");
    var request = http.MultipartRequest("POST", uri);

    // Find selected category ID
    var selectedCategoryId = _categories.firstWhere(
          (cat) => cat["name"] == _selectedCategory,
      orElse: () => {"id": null},
    )["id"];

    var selectedUnitId = _quantitUnit.firstWhere(
          (cat) => cat["name"] == _selectedUnit,
      orElse: () => {"id": null},
    )["id"];

    //request.fields["category_id"] = "1";
    //request.fields["unit_id"] = "1";
    request.fields["item_name"] = itemNameController.text;
    request.fields["category_id"] = selectedCategoryId.toString();
    request.fields["unit_id"] = selectedUnitId.toString();
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

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item Added Successfully!")),
        );
        clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add item!")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

  }

  // Clear All Fields After Upload
  void clearForm() {
    itemNameController.clear();
    descriptionController.clear();
    purchasePriceController.clear();
    salePriceController.clear();
    taxPercentController.clear();
    taxPriceController.clear();
    netPriceController.clear();
    minQuantityController.clear();
    _images.clear();
    _selectedCategory = null;
    _selectedUnit = null; // Fixed: Reset _selectedUnit as well
    notifyListeners();
  }
}
