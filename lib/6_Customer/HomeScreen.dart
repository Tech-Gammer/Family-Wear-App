import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../2_Assets/Colors/Colors_Scheme.dart';
import '1_MainScreen/Cart_Screen/CartScreen.dart';
import '1_MainScreen/Cart_Screen/Cart_provider.dart';
import '1_MainScreen/Home_Tab_Screen/HomeTabScreen.dart';
import '1_MainScreen/Profile_Screen/ProfileScreen.dart';
import '1_MainScreen/Wishlist_Screen/WishlistScreen.dart';
import '2_CustomerProviders/GNav_bar_Provider.dart';
import '2_CustomerProviders/HomeTabScreen_Provider.dart';


class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<Widget> screens = [
    HomeTabScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        exit(0);
        return false;
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
        bottomNavigationBar: _buildBottomNavigationBar(context, theme, isDarkTheme, userProvider),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ThemeData theme, bool isDarkTheme, UserProvider userProvider) {
    final provider = Provider.of<GNavBarProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      color: isDarkTheme ? AppColors.accentColor : AppColors.background,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 8,
        ),
        child: GNav(
          gap: 8,
          tabBorderRadius: 15,
          activeColor: AppColors.primaryColor,
          iconSize: 24,
          textSize: 12,
          tabBackgroundColor: AppColors.primaryColor.withOpacity(0.2),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          selectedIndex: provider.selectedIndex,
          // onTabChange: (index) {
          //   provider.updateSelectedIndex(index);
          //   if (index == 2 && userProvider.userId != null) {
          //     cartProvider.fetchCartItems(userId: userProvider.userId.toString());
          //   }
          // },
            onTabChange: (index) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.updateSelectedIndex(index);
                if (index == 2 && userProvider.userId != null) {
                  cartProvider.fetchCartItems(userId: userProvider.userId.toString());
                }
              });
            },

            tabs: _navItems.map((item) {
            final isActive = _navItems.indexOf(item) == provider.selectedIndex;
            return GButton(
              icon: isActive ? item['activeIcon'] : item['icon'],
              text: item['label'],
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDarkTheme ? AppColors.lightTextColor : AppColors.darkTextColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {'icon': Icons.favorite_border_outlined, 'activeIcon': Icons.favorite, 'label': 'Wishlist'},
    {'icon': Icons.shopping_cart_outlined, 'activeIcon': Icons.shopping_cart, 'label': 'Cart'},
    {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
  ];
}