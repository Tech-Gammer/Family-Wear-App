import 'dart:convert';
import 'dart:io';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddCategoryProvider with ChangeNotifier {
  File? _image;
  final TextEditingController _nameController = TextEditingController();

  // Getter
  File? get image => _image;
  TextEditingController get nameController => _nameController;

  // Setter
  set image(File? newImage) {
    _image = newImage;
    notifyListeners();
  }

  void removeImage() {
    image = null;
    notifyListeners();
  }


  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
  }

  Future<void> uploadCategory(BuildContext context) async {
    if (_nameController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter name and select image")));
      return;
    }

    var request = http.MultipartRequest(
      "POST", Uri.parse("http://${NetworkConfig().ipAddress}:5000/add-category"),
    );
    request.fields["category_name"] = _nameController.text;
    request.files.add(await http.MultipartFile.fromPath("category_picture", _image!.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse["message"])));

    _nameController.clear();
    image = null;

  }
}



/*
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../ip_address.dart';

class AddCategoryProvider with ChangeNotifier {
  File? _image;
  final TextEditingController _nameController = TextEditingController();

  File? get image => _image;
  TextEditingController get nameController => _nameController;

  set image(File? newImage) {
    _image = newImage;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
  }

  Future<void> uploadCategory(BuildContext context) async {
    if (_nameController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter name and select image")));
      return;
    }

    var request = http.MultipartRequest(
      "POST", Uri.parse("http://${NetworkConfig().ipAddress}:5000/add-category"),
    );
    request.fields["category_name"] = _nameController.text;
    request.files.add(await http.MultipartFile.fromPath("category_picture", _image!.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse["message"])));

    clearData();
  }

  void clearData() {
    _nameController.clear();
    _image = null;
    notifyListeners();
  }
}
*/
