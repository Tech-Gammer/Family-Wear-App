/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../4_Provider/intro_Provider/Splash_Provider.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Trigger initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SplashProvider>(context, listen: false).initializeApp(context);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFF4747), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              height: screenHeight * 0.1, // 10% of screen height
              width: screenWidth * 0.2,  // 20% of screen width
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.ac_unit, // Replace with your logo
                size: screenHeight * 0.05, // 5% of screen height
                color: const Color(0xFFFF4747),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // App Name Text
            Text(
              'Family Wear', // Replace with your text
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight * 0.02, // 2% of screen height
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Add this import for SystemChrome
import '../../4_Provider/intro_Provider/Splash_Provider.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Trigger initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SplashProvider>(context, listen: false).initializeApp(context);
    });

    // Set only the status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      statusBarColor: const Color(0xFFFF4747), // Set status bar color
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFF4747), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              height: screenHeight * 0.1, // 10% of screen height
              width: screenWidth * 0.2,  // 20% of screen width
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.ac_unit, // Replace with your logo
                size: screenHeight * 0.05, // 5% of screen height
                color: const Color(0xFFFF4747),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // App Name Text
            Text(
              'Family Wear', // Replace with your text
              style: TextStyle(
                color: Colors.white,
                fontSize: screenHeight * 0.02, // 2% of screen height
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

