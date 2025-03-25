import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarProvider with ChangeNotifier {
  Color _statusBarColor = Colors.transparent;
  Brightness _statusBarIconBrightness = Brightness.light;

  Color get statusBarColor => _statusBarColor;
  Brightness get statusBarIconBrightness => _statusBarIconBrightness;

  void setStatusBar(Color color, Brightness iconBrightness) {
    _statusBarColor = color;
    _statusBarIconBrightness = iconBrightness;

    // Apply the system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: _statusBarColor,
        statusBarIconBrightness: _statusBarIconBrightness,
      ),
    );

    notifyListeners(); // Notify listeners about the change
  }
}
