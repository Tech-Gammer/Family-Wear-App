import 'dart:async';
import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {
  final List<String> _placeholders = [
    "Search for products",
    "Search for categories",
    "Search for brands",
  ];
  int _currentPlaceholderIndex = 0;
  String _currentPlaceholder = "Search for products";
  bool _isUserTyping = false;
  late Timer _timer;

  SearchProvider() {
    // Start the placeholder rotation timer
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isUserTyping) {
        _currentPlaceholderIndex =
            (_currentPlaceholderIndex + 1) % _placeholders.length;
        _currentPlaceholder = _placeholders[_currentPlaceholderIndex];
        notifyListeners();
      }
    });
  }

  String get currentPlaceholder => _currentPlaceholder;

  void userStartedTyping() {
    _isUserTyping = true;
    notifyListeners();
  }

  void userStoppedTyping() {
    _isUserTyping = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
