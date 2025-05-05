  import 'package:family_wear_app/6_Customer/1_MainScreen/Profile_Screen/reportList.dart';
import 'package:family_wear_app/6_Customer/1_MainScreen/Profile_Screen/reportbugpage.dart';
import 'package:family_wear_app/6_Customer/1_MainScreen/Profile_Screen/securityPage.dart';
import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../../../1_Auth/Intro/2_Create_Account_Page/Profile_Page.dart';
  import '../../../1_Auth/Intro/2_Create_Account_Page/register_page.dart';
  import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
  import '../../../2_Assets/Colors/Colors_Scheme.dart';
  import '../../../4_Provider/theme.dart';
import '../../../5_Admin/1_AdminHomeScreen.dart';
  import '../../../7_Moderator/Moderator.dart';
  import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
  import '../OrdersScreens/OrdersListPage.dart';
import 'helpCenter.dart';


  class ProfileScreen extends StatefulWidget {
    const ProfileScreen({Key? key}) : super(key: key);

    @override
    _ProfileScreenState createState() => _ProfileScreenState();
  }

  class _ProfileScreenState extends State<ProfileScreen> {
    bool _isLoading = true;

    @override
    void initState() {
      super.initState();
      _loadUserData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userId = Provider.of<UserProvider>(context, listen: false).userId;
        if (userId != null) {
          Provider.of<ProfileProvider>(context, listen: false).initializeProfile(userId);
        }
      });
    }

    Future<void> _loadUserData() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.userId == null) {
        final success = await userProvider.loadUserDataFromPrefs();
        if (!success) {
          // Handle not logged in state
          return;
        }
      }

      // Force refresh from server
      await userProvider.fetchUserData();
      setState(() => _isLoading = false);
    }

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
                  // Get the user provider
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  // Clear user data
                  await userProvider.clearUserData();

                  Navigator.of(context).pop(); // Close the dialog

                  // Navigate to login/register screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => CreateAccountScreen()),
                        (Route<dynamic> route) => false,
                  );

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
    }

    @override
    Widget build(BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      final theme = Theme.of(context);
      final isDarkTheme = theme.brightness == Brightness.dark;
      // Access user data from provider
      final userProvider = Provider.of<UserProvider>(context);

      return SafeArea(
        child: Scaffold(
          backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : AppColors.lightBackgroundColor,
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                    trailing:IconButton(onPressed: (){
                      if (userProvider.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(userId: userProvider.userId!),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User ID is not available!")));
                      }
                    }, icon: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04, color: AppColors.darkTextColor)),
                    // leading: CircleAvatar(
                    //   backgroundImage: userProvider.imageUrl.isNotEmpty
                    //       ? NetworkImage(userProvider.imageUrl) as ImageProvider
                    //       : AssetImage('asset/ring.jpg'),
                    //   radius: screenWidth * 0.06,
                    // ),
                    title: Row(
                      children: [
                        Text(
                            userProvider.name.isNotEmpty ? userProvider.name : userProvider.userName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04, color: AppColors.darkTextColor)
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Icon(Icons.verified, color: Colors.blue, size: screenWidth * 0.05),
                      ],
                    ),
                    subtitle: Text(
                        userProvider.email,
                        style: TextStyle(fontSize: screenWidth * 0.03, color: AppColors.darkTextColor)
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingsItem(Icons.payment, "Purchases", screenWidth,(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MyOrdersScreen()));
                  }),
                  Divider(),
                  const SizedBox(height: 5),
                  const Text("Settings & Preference",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // _buildSettingsItem(Icons.notifications, "Notifications", screenWidth,(){}),
                  // _buildSettingsItem(Icons.language, "Language", screenWidth,(){}),
                  _buildSettingsItem(Icons.security, "Security", screenWidth,(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AppSecurityFeaturesPage()));
                  }),
                  //_buildToggleItem(Icons.dark_mode, "Dark mode", screenWidth),
                  _buildToggleItem(Icons.dark_mode, "Dark mode", screenWidth),
                  Divider(),
                  const SizedBox(height: 5),
                  const Text("Support",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildSettingsItem(Icons.help, "Help center", screenWidth,(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HelpCenterPage()));
                  }),
                  _buildSettingsItem(Icons.bug_report, "Report a bug", screenWidth,(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportBugPage()));

                  }),
                  _buildSettingsItem(Icons.bug_report, "Report List", screenWidth,(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>UserBugReportsPage()));

                  }),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: Icon(Icons.logout, color: AppColors.primaryColor, size: screenWidth * 0.06),
                    title: Text("Log out", style: TextStyle(color: AppColors.primaryColor, fontSize: screenWidth * 0.045)),
                    onTap: () => _showLogoutDialog(context),
                  ),
                  if (userProvider.role == 0 || userProvider.role == 2)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: userProvider.role == 0 ? Colors.deepPurple : Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenWidth * 0.06,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.dashboard),
                        label: Text(
                          userProvider.role == 0 ? 'Go to Admin Panel' : 'Go to Moderator Panel',
                          style: TextStyle(fontSize: screenWidth * 0.045),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => userProvider.role == 0
                                  ?  AdminHomeScreen()
                                  :  ModeratorPanel(),
                            ),
                          );
                        },
                      ),
                    ),

                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildSettingsItem(IconData icon, String title, double screenWidth, ontap) {
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
          onTap: ontap,
        ),
      );
    }

    Widget _buildToggleItem(IconData icon, String title, double screenWidth) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SwitchListTile(
              secondary: Icon(icon, size: screenWidth * 0.06),
              title: Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme(value);
              },
            ),
          );
        },
      );
    }
  }