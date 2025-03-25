import 'dart:convert';
import 'package:family_wear_app/1_Auth/Intro/1_first_Three_Screen/first_Screen.dart';
import 'package:family_wear_app/1_Auth/Intro/2_Create_Account_Page/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../../../4_Provider/intro_Provider/First_Three_Provider.dart';
import '../../../4_Provider/statusBarColor_Provider.dart';
import 'package:flutter/material.dart';

import '../../../ip_address.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Logout Confirmation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.05,
              letterSpacing: 1,
              color: Colors.black87, // Added for better readability
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black54, // Subtle text color
            ),
          ),
          //actionsAlignment: MainAxisAlignment.spaceAround, // Better button alignment
          actions: [
            // Cancel Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.black),
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            // Logout Button
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Logout logic
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => CreateAccountScreen
                    ()),
                      (Route<dynamic> route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully!'),
                    backgroundColor: Colors.green, // Success color
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.lightTextColor,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : AppColors.lightBackgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(child: Text('My Profile', style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold, letterSpacing: 2))),
                SizedBox(height: screenHeight * 0.015),
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04, color: AppColors.darkTextColor,),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('asset/ring.jpg'),
                    radius: screenWidth * 0.06,
                  ),
                  title: Row(
                    children: [
                      Text("Muhammad Sufyan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04, color: AppColors.darkTextColor )),
                      SizedBox(width: screenWidth * 0.02),
                      Icon(Icons.verified, color: Colors.blue, size: screenWidth * 0.05),
                    ],
                  ),
                  subtitle: Text("sufyanbutt@gmail.com", style: TextStyle(fontSize: screenWidth * 0.03, color: AppColors.darkTextColor)),
                ),
                const SizedBox(height: 10),
                _buildSettingsItem(Icons.payment, "Payments & purchases", screenWidth),
                Divider(),
                const SizedBox(height: 5),
                const Text("Settings & Preference",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    //color: Colors.black87,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                _buildSettingsItem(Icons.notifications, "Notifications", screenWidth),
                _buildSettingsItem(Icons.language, "Language", screenWidth),
                _buildSettingsItem(Icons.security, "Security", screenWidth),
                _buildToggleItem(Icons.dark_mode, "Dark mode", screenWidth),
                Divider(),
                const SizedBox(height: 5),
                const Text("Support",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    //color: Colors.black87,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                _buildSettingsItem(Icons.help, "Help center", screenWidth),
                _buildSettingsItem(Icons.bug_report, "Report a bug", screenWidth),
                const SizedBox(height: 10),
                ListTile(
                  //tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  leading: Icon(Icons.logout, color: AppColors.primaryColor, size: screenWidth * 0.06),
                  title: Text("Log out", style: TextStyle(color: AppColors.primaryColor, fontSize: screenWidth * 0.045)),
                  onTap: () => _showLogoutDialog(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, size: screenWidth * 0.06),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.04)),
        trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04),
        onTap: () {},
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, size: screenWidth * 0.06),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: screenWidth * 0.04)),
        value: false,
        onChanged: (bool value) {},
      ),
    );
  }
}
