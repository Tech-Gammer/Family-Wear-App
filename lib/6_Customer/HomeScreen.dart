import 'dart:io';
import 'package:family_wear_app/6_Customer/2_CustomerProviders/GNav_bar_Provider.dart';
import 'package:family_wear_app/raaf_Page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../2_Assets/Colors/Colors_Scheme.dart';
import '1_MainScreen/Cart_Screen/CartScreen.dart';
import '1_MainScreen/Home_Tab_Screen/HomeTabScreen.dart';
import '1_MainScreen/Profile_Screen/ProfileScreen.dart';
import '1_MainScreen/Wishlist_Screen/WishlistScreen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeTabScreen(),
      WishlistScreen(),
      Raaf(),
      ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        exit(0); // Directly exit the app
        return false; // Required for proper functionality
      },
      child: Scaffold(
        body: Consumer<GNavBarProvider>(
          builder: (context, provider, child) {
            return IndexedStack(
              index: provider.selectedIndex,
              children: screens,
            );
          },
        ),
        bottomNavigationBar:
        _buildBottomNavigationBar(context, theme, isDarkTheme),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ThemeData theme, bool isDarkTheme) {
    final provider = Provider.of<GNavBarProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Base sizes
    double baseFontSize = 12;
    double responsiveFontSize = baseFontSize * (screenWidth / 375);
    double baseIconSize = 24;
    double responsiveIconSize = baseIconSize * (screenWidth / 375);
    double basePadding = 8;
    double responsivePadding = basePadding * (screenWidth / 375);

    return Container(
      color: isDarkTheme ? AppColors.accentColor : AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // Fixed padding for structure
          vertical: screenHeight * 0.005,
        ),
        child: GNav(
          gap: screenWidth * 0.02, // Responsive gap
          tabBorderRadius: 15,
          activeColor: AppColors.primaryColor,
          iconSize: responsiveIconSize, // Responsive icon size
          textSize: responsiveFontSize * 0.75, // Adjusted for GNav text size
          tabBackgroundColor: AppColors.primaryColor.withOpacity(0.2),
          backgroundColor: isDarkTheme? AppColors.accentColor : AppColors.background.withOpacity(0.6),
          padding: EdgeInsets.symmetric(horizontal: responsivePadding * 1.6, vertical: responsivePadding),
          selectedIndex: provider.selectedIndex,
          onTabChange: (index) => provider.updateSelectedIndex(index),
          tabs: _navItems.map((item) {
            final isActive = _navItems.indexOf(item) == provider.selectedIndex;
            return GButton(
              icon: isActive ? item['activeIcon'] : item['icon'],
              text: item['label'],
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize, // Responsive text size
                color: isDarkTheme ? AppColors.lightTextColor : AppColors.darkTextColor),
            );
          }).toList(),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.favorite_border_outlined,
      'activeIcon': Icons.favorite,
      'label': 'Wishlist',
    },
    {
      'icon': Icons.shopping_cart_outlined,
      'activeIcon': Icons.shopping_cart,
      'label': 'Cart',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profile',
    },
  ];
}
