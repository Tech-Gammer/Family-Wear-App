import 'package:flutter/material.dart';
import '../../1_Auth/Intro/1_first_Three_Screen/first_Screen.dart';


class SplashProvider extends ChangeNotifier {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> initializeApp(BuildContext context) async {
    // Simulate initialization or data loading
    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();

    // Navigate to the Home Page after loading
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FirstScreen()), // Replace with your Home Page
    );
  }
}
