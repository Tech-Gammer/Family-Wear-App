import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:family_wear_app/5_Admin/AdminHomePages/Category_Management/addCategory.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Category_Management/showCategory.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/add_item.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Unit_Managment/add_unit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../1_Auth/Intro/2_Create_Account_Page/register_page.dart';
import '../2_Assets/Colors/Colors_Scheme.dart';
import '../6_Customer/2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../6_Customer/HomeScreen.dart';
import '../raaf3.dart';
import 'AdminHomePages/BugReportPages/reportbugspages.dart';
import 'AdminHomePages/Item_Managment/Show_items.dart';
import 'AdminHomePages/Item_Managment/inactiveitemPage.dart';
import 'AdminHomePages/Item_Managment/item_Purchase.dart';
import 'AdminHomePages/Item_Managment/purchaseList.dart';
import 'AdminHomePages/Order_Managment/adminOrderList.dart';
import 'AdminHomePages/Order_Managment/ordercancellation.dart';
import 'AdminHomePages/Order_Managment/pendingorderprovider.dart';
import 'AdminHomePages/Order_Managment/reportpage.dart';
import 'AdminHomePages/Slider_Management/addSlider.dart';
import 'AdminHomePages/Slider_Management/showSlider.dart';
import 'AdminHomePages/Unit_Managment/show_unit.dart';
import 'AdminHomePages/adminpages/usersListPage.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {

  @override
  void initState() {
    super.initState();

    // Fetch pending order count on load
    Future.delayed(Duration.zero, () {
      Provider.of<PendingOrdersProvider>(context, listen: false)
          .fetchPendingOrdersCount();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;
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
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.black54,
                ),
              ),
              actions: [
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
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateAccountScreen()),
                            (Route<dynamic> route) => false);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully!'),
                        backgroundColor: Colors.green,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title:
          Text('Admin Home', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            Consumer<PendingOrdersProvider>(
              builder: (context, pendingProvider, _) {
                final count = pendingProvider.pendingCount;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminOrdersScreen()),
                        );
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],

          //backgroundColor: AppColors.primaryColor,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildDrawerHeader(),
              // In your drawer widget
              /*Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return UserAccountsDrawerHeader(
                        accountName: Text(
                          userProvider.userName
                          // userProvider.name.isNotEmpty
                          //     ? userProvider.name
                          //     : 'Guest User',
                        ),
                        accountEmail: Text(userProvider.email),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: userProvider.imageUrl.isNotEmpty
                              ? NetworkImage(userProvider.imageUrl)
                              : null,
                          child: userProvider.imageUrl.isEmpty
                              ? Icon(Icons.person)
                              : null,
                        ),
                      );
                    },
                  ),*/
              buildListTile(
                  Icons.dashboard,
                  'Dashboard',
                      () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminHomeScreen()))),
              buildListTile(Icons.shopping_cart, 'Order Management', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminOrdersScreen()));
              }),
              buildSectionTitle('Item Management'),
              buildListTile(
                  Icons.add,
                  'Add Item',
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddItem()))),
              buildListTile(
                  Icons.add,
                  'Add Purchase',
                      () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PurchaseItemPage()))),
              buildListTile(
                  Icons.list,
                  'Show Items',
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShowItemPage()))),
              buildListTile(
                  Icons.list,
                  'Manage Inactive Items',
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => InactiveItemsPage()))),
              buildListTile(
                  Icons.list,
                  'Show Purchases',
                      () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PurchaseListPage()))),
              buildSectionTitle('Category Management'),
              buildListTile(
                  Icons.add,
                  'Add Category',
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddCategory()))),
              buildListTile(
                  Icons.list,
                  'Show Categories',
                      () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowCategories()))),
              buildSectionTitle('Slider Management'),
              buildListTile(
                  Icons.add,
                  'Add Slider',
                      () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UploadImageScreen()))),
              buildListTile(
                  Icons.list,
                  'Show Sliders',
                      () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowSliderScreen()))),
              buildSectionTitle('Units Management'),
              buildListTile(
                  Icons.add,
                  'Add Units',
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddUnitPage()))),
              buildListTile(
                  Icons.list,
                  'Show Units',
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShowUnitPage()))),
              // buildSectionTitle('Notification Management'),
              // buildListTile(Icons.add, 'Add Notification', () {}),
              // buildListTile(Icons.list, 'Show Notifications', () {}),
              Divider(),
              buildListTile(
                  Icons.list,
                  'Go To Customer Side',
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()))),
              buildListTile(
                  Icons.exit_to_app, 'Logout', () => _showLogoutDialog(context),
                  color: Colors.red),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
            return GridView.count(
              padding: EdgeInsets.all(10),
              crossAxisCount: crossAxisCount,
              children: [
                buildCard(
                    'Orders',
                    Icons.shopping_cart,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminOrdersScreen()))),
                buildCard(
                    'Products',
                    Icons.inventory,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowItemPage()))),
                buildCard(
                    'Categories',
                    Icons.category,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowCategories()))),
                buildCard(
                    'Sliders',
                    Icons.slideshow,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowSliderScreen()))),
                buildCard(
                    'Units',
                    Icons.widgets,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowUnitPage()))),
                buildCard(
                    'Cancellation Requests',
                    Icons.widgets,
                        () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AdminCancellationRequestsScreen()))),
                buildCard(
                    'Users List',
                    Icons.widgets,
                        () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AdminsPage()))),
                buildCard('Bug Reports', Icons.notifications, (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminBugReportsPage()));
                }
                ),
                buildCard(
                  'Reports',
                  Icons.bar_chart,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminReportsScreen()),
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildDrawerHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return DrawerHeader(
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            image: DecorationImage(
              image: AssetImage('asset/logo.PNG'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset('asset/logo.PNG', fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(userProvider.userName,
                          style: TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(userProvider.email,
                          style: TextStyle(
                            color: AppColors.lightTextColor.withOpacity(0.8),
                            fontSize: 14,
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildListTile(IconData icon, String title, VoidCallback onTap,
      {Color color = AppColors.primaryColor}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget buildSectionTitle(String title) {
    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget buildCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: AppColors.primaryColor),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

