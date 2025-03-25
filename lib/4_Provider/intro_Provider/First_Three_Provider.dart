import 'package:flutter/material.dart';

class PageNotifier extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  void nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
      notifyListeners(); // Notify listeners when the page changes
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners(); // Notify listeners when the page changes
    }
  }

  void setPage(int index) {
    _currentPage = index;
    notifyListeners();
  }
}
