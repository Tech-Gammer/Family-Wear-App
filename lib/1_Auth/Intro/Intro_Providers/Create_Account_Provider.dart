// second
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../ip_address.dart';
import '../../../raaf_Page.dart';
import '../2_Create_Account_Page/Profile_Page.dart';

class CreateAccountProvider with ChangeNotifier {
  // State variables
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isPasswordVisible1 = false;
  bool _isPasswordVisible2 = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;
  String _deviceToken = "";

  // Getters
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get deviceToken => _deviceToken;
  bool get isPasswordVisible1 => _isPasswordVisible1;
  bool get isPasswordVisible2 => _isPasswordVisible2;
  bool get isTermsAccepted => _isTermsAccepted;
  bool get isLoading => _isLoading;

  NetworkConfig config = NetworkConfig();

  //String ip_address = "192.168.100.179";

  // Setters
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void setDeviceToken(String value) {
    _deviceToken = value;
    notifyListeners();
  }

  void togglePasswordVisibility1() {
    _isPasswordVisible1 = !_isPasswordVisible1;
    notifyListeners();
  }

  void togglePasswordVisibility2() {
    _isPasswordVisible2 = !_isPasswordVisible2;
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    _isTermsAccepted = value;
    notifyListeners();
  }



// Form submission with enhanced error handling and validation
  /*Future<void> submitForm(BuildContext context) async {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must accept the Terms & Conditions")),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('http://192.168.100.179:5000/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_name': _name,
          'email': _email,
          'password': _password,
          'token': _deviceToken,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        final int userId = responseData["user_id"];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User registered successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Registration failed.")),
        );
      }
    } catch (error) {
      debugPrint("Error during registration: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }*/

  Future<void> submitForm(BuildContext context) async {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must accept the Terms & Conditions")),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('http://${config.ipAddress}:5000/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_name': _name,
          'email': _email,
          'password': _password,
          'token': _deviceToken,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        final int userId = responseData["user_id"];
        final int role = responseData["role"];

        // Save user details in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', userId);
        await prefs.setInt('role', role);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User registered successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(userId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Registration failed.")),
        );
      }
    } catch (error) {
      debugPrint("Error during registration: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}

