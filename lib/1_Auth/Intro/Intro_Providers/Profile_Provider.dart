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
  bool _isLoading = false;

  NetworkConfig config = NetworkConfig();


  // Getters
  String? get gender => _gender;
  String? get profileImageUrl => _profileImageUrl;
  File? get profileImageFile => _profileImageFile;

  // Initialize profile data
  Future<void> initializeProfile(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('http://${config.ipAddress}:5000/user/$userId'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        // nameController.text = userData['name'] ?? '';
        // phoneNumberController.text = userData['phone_no'] ?? '';
        nameController.text = userData['name']?.toString() ?? '';
        phoneNumberController.text = userData['phone_no']?.toString() ?? '';

        _gender = userData['gender'];
        _profileImageUrl = userData['user_image'] != null
            ? 'http://${config.ipAddress}:5000/uploads/${userData['user_image']}'
            : null;
      }
    } catch (e) {
      throw Exception('Failed to load profile: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    if (_profileImageFile == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://${config.ipAddress}:5000/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath(
          'user_image',
          _profileImageFile!.path
      ));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final filename = jsonDecode(responseData)['filename'];
        _profileImageUrl = 'http://${config.ipAddress}:5000/uploads/$filename';
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitProfile(BuildContext context, int userId) async {
    try {
      _validateInputs();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('http://${config.ipAddress}:5000/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'name': nameController.text,
          'phone_no': phoneNumberController.text,
          'gender': _gender,
          'user_image': _profileImageUrl?.split('/').last,
        }),
      );

      _handleResponse(response, context, prefs);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  void _validateInputs() {
    if (nameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        _gender == null) {
      throw Exception('Please fill all required fields');
    }

    if (!RegExp(r'^(03[0-9]{9})|(\+923[0-9]{9})$').hasMatch(phoneNumberController.text)) {
      throw Exception('Invalid phone number format. Please use 03216455926 or +923416455926');
    }

  }

  void _handleResponse(http.Response response, BuildContext context, SharedPreferences prefs) {
    if (response.statusCode == 200) {
      prefs.setBool('isProfileComplete', true);
      _navigateBasedOnRole(context, prefs.getInt('role'));
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again');
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Update failed');
    }
  }

  void _navigateBasedOnRole(BuildContext context, int? role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => role == 0 ? AdminHomeScreen() : HomeScreen(),
      ),
    );
  }

  // Clear state
  void clearProfile() {
    nameController.clear();
    phoneNumberController.clear();
    _gender = null;
    _profileImageUrl = null;
    _profileImageFile = null;
    notifyListeners();
  }


}



