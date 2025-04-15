import 'dart:convert';
import 'dart:io';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddSliderImageProvider with ChangeNotifier {
  File? _image;

  // Getter
  File? get image => _image;

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

  Future<void> uploadSliderImage(BuildContext context) async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image")));
      return;
    }

    var request = http.MultipartRequest(
      "POST", Uri.parse("http://${NetworkConfig().ipAddress}:5000/upload_image"),
    );

    request.files.add(await http.MultipartFile.fromPath("slider_image", _image!.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse["message"])));

    image = null; // Clear image after upload
  }
}
