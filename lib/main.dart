import 'package:family_wear_app/1_Auth/Intro/1_first_Three_Screen/first_Screen.dart';
import 'package:family_wear_app/1_Auth/Intro/Intro_Providers/Create_Account_Provider.dart';
import 'package:family_wear_app/1_Auth/Intro/Intro_Providers/Login_Provider.dart';
import 'package:family_wear_app/1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Category_Management/addCategory_Provider.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/addItem_provider.dart';
import 'package:family_wear_app/6_Customer/2_CustomerProviders/HomeTabScreen_Provider.dart';
import 'package:family_wear_app/raaf_Page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '2_Assets/Colors/Colors_Scheme.dart';
import '4_Provider/intro_Provider/First_Three_Provider.dart';
import '4_Provider/intro_Provider/Splash_Provider.dart';
import '4_Provider/statusBarColor_Provider.dart';
import '4_Provider/theme.dart';
import '5_Admin/1_AdminHomeScreen.dart';
import '5_Admin/AdminHomePages/Category_Management/showCategory_Provider.dart';
import '5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
import '5_Admin/AdminHomePages/Item_Managment/Show_items.dart';
import '6_Customer/2_CustomerProviders/Category_Provider.dart';
import '6_Customer/2_CustomerProviders/GNav_bar_Provider.dart';
import '6_Customer/2_CustomerProviders/Item_Provider.dart';
import '6_Customer/2_CustomerProviders/HomeScrollProvider.dart';
import '6_Customer/2_CustomerProviders/Search_Provider.dart';
import '6_Customer/HomeScreen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final role = prefs.getInt('role') ?? -1; // -1 means not logged in

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<SplashProvider>(create: (_) => SplashProvider()),
        ChangeNotifierProvider<PageNotifier>(create: (_) => PageNotifier()),
        ChangeNotifierProvider<GNavBarProvider>(create: (_) => GNavBarProvider()),
        ChangeNotifierProvider(create: (_) => StatusBarProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => HorizontalScrollProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => CreateAccountProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AddCategoryProvider()),
        ChangeNotifierProvider(create: (_) => ShowCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AddItemProvider()),
        ChangeNotifierProvider(create: (_) => ShowItemProvider()),
      ],
      child:  MyApp(
        isLoggedIn: isLoggedIn,
        role: role,
      ),
    ),
  );
}

/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Family Wear',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              final userRole = snapshot.data!['role'];
              if (userRole == 0) {
                return AdminHomeScreen();
              } else if (userRole == 1) {
                return HomeTabScreen();
              } else {
                return FirstScreen();
              }
            } else {
              return FirstScreen();
            }
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');
    if (userData != null) {
      return json.decode(userData);
    }
    return {};
  }
}*/

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final int role;

  const MyApp({Key? key, required this.isLoggedIn, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Family Wear',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? _getHomePageBasedOnRole(role) : FirstScreen(),
    );
  }

  Widget _getHomePageBasedOnRole(int role) {
    switch (role) {
      case 0:
        return AdminHomeScreen(); // Admin
      case 1:
        return HomeScreen(); // User
      case 2:
        return HomeScreen(); // Moderator
      default:
        //return Raaf(); // Unknown role, show default page
        return FirstScreen(); // Not logged in
    }
  }
}
