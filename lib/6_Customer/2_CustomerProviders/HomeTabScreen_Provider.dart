
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../ip_address.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  int? _userId;
  String _userName = "";
  String _name = "";
  String _email = "";
  String _imageUrl = "";
  int? _role;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int? get userId => _userId;
  String get userName => _userName;
  String get name => _name;
  String get email => _email;
  String get imageUrl => _imageUrl;
  int? get role => _role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load data from SharedPreferences on app start
  Future<bool> loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      _userId = prefs.getInt('userId');
      _role = prefs.getInt('role');
      _userName = prefs.getString('userName') ?? "";
      _email = prefs.getString('email') ?? "";
      _name = prefs.getString('name') ?? "";
      _imageUrl = prefs.getString('user_image') ?? "";
      notifyListeners();
      return true;
    }
    return false;
  }

  // Add imageUrl parameter
  Future<void> setUserData(int userId, int role, String userName, String email, [String imageUrl = ""]) async {
    _userId = userId;
    _role = role;
    _userName = userName;
    _email = email;
    _imageUrl = imageUrl;

    // Save to SharedPreferencess
    await saveUserDataToPrefs();
    notifyListeners();

    // Fetch additional data if image not provided
    if (imageUrl.isEmpty) {
      await fetchUserData();
    }
  }

  Future<void> saveUserDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (_userId != null) prefs.setInt('userId', _userId!);
    if (_role != null) prefs.setInt('role', _role!);
    prefs.setString('userName', _userName);
    prefs.setString('email', _email);
    prefs.setString('name', _name);
    prefs.setString('user_image', _imageUrl);
  }

  // Error handling
  void _handleError(String message) {
    _errorMessage = message;
    _isLoading = false;
    debugPrint(message);
    notifyListeners();
  }

  // Clear user data (for logout)
  Future<void> clearUserData() async {
    _userId = null;
    _userName = "";
    _name = "";
    _email = "";
    _imageUrl = "";
    _role = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    if (_userId == null) {
      _handleError("User ID not available");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("http://${NetworkConfig().ipAddress}:5000/user/$_userId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateUserData(data);
        await saveUserDataToPrefs();
      } else {
        _handleError("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (error) {
      _handleError("Connection error: ${error.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateUserData(Map<String, dynamic> data) {
    _name = data['name'] ?? _name;
    _email = data['email'] ?? _email;
    _imageUrl = data['user_image']?.toString() ?? _imageUrl;
    _role = data['role'] ?? _role;
    _userName = data['user_name'] ?? _userName;
    notifyListeners();
  }
}