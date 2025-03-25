import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../ip_address.dart';

class UserProvider with ChangeNotifier {

  String _name = "";
  String _email = "";
  String _imageUrl = "";
  bool _isLoading = false;

  String get name => _name;
  String get email => _email;
  String get imageUrl => _imageUrl;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData(int userId, String userName, String email) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/user"); // Change IP if needed
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
          "user_name": userName,
          "email": email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _name = data['user_name'];
        _email = data['email'];
        _imageUrl = data['user_image'];
      } else {
        print("Error: ${response.body}");
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }

    _isLoading = false;
    notifyListeners();
  }
}
