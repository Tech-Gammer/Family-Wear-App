// Second
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../5_Admin/1_AdminHomeScreen.dart';
import '../../../6_Customer/HomeScreen.dart';
import '../../../ip_address.dart';


class ProfileProvider with ChangeNotifier {
  // State variables
  String? _gender;
  String? _profileImageUrl;
  File? _profileImageFile;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  NetworkConfig config = NetworkConfig();

  //String ip_address = "192.168.100.179";


  // Getters
  String? get gender => _gender;
  String? get profileImageUrl => _profileImageUrl;
  File? get profileImageFile => _profileImageFile;

  // Setters
  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setProfileImageUrl(String? value) {
    _profileImageUrl = value;
    notifyListeners();
  }

  void setProfileImageFile(File? file) {
    _profileImageFile = file;
    notifyListeners();
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _profileImageFile = File(image.path);
        notifyListeners();
      } else {
        throw Exception("No image selected");

      }
    } catch (e) {
      throw Exception("Error picking image: $e");
    }
  }

  // Upload image to the server
  Future<void> uploadImage() async {
    if (_profileImageFile == null) {
      throw Exception("Please select an image first.");
    }
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("http://${config.ipAddress}:5000/upload"),
    );

    request.files.add(
      await http.MultipartFile.fromPath("user_image", _profileImageFile!.path),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      _profileImageUrl = jsonDecode(responseBody)['imageUrl'];
      notifyListeners();
    } else {
      throw Exception("Upload failed: ${response.reasonPhrase}");
    }
  }

  // Submit profile data to the server
/*
  Future<void> submitProfile(BuildContext context, int userId) async {
    if (nameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        _gender == null ||
        _profileImageUrl == null) {
      throw Exception("Please fill all fields and upload an image.");
    }

    final url = Uri.parse('http://192.168.100.179:5000/profile');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "name": nameController.text,
        "phone_no": phoneNumberController.text,
        "gender": _gender,
        "user_image": _profileImageUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Update Failed: ${response.body}");
    }
  }
*/

  Future<void> submitProfile(BuildContext context, int userId) async {
    if (nameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        _gender == null ||
        _profileImageUrl == null) {
      throw Exception("Please fill all fields and upload an image.");
    }

    final url = Uri.parse('http://${config.ipAddress}:5000/profile');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "name": nameController.text,
        "phone_no": phoneNumberController.text,
        "gender": _gender,
        "user_image": _profileImageUrl,
      }),
    );

    if (response.statusCode == 200) {
      // Save profile completion status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isProfileComplete', true);

      // Redirect to Home Page based on role
      final role = prefs.getInt('role') ?? -1;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => role == 0 ? AdminHomeScreen() : HomeScreen(),
        ),
      );
    } else {
      throw Exception("Update Failed: ${response.body}");
    }
  }

}



