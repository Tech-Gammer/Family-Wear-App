// import 'dart:math';
//
// import 'package:family_wear_app/1_Auth/Intro/2_Create_Account_Page/register_page.dart';
// import 'package:family_wear_app/6_Customer/HomeScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../../../2_Assets/Colors/Colors_Scheme.dart';
// import '../../../5_Admin/1_AdminHomeScreen.dart';
// import '../../../ip_address.dart';
//
// class LoginAccount extends StatefulWidget {
//   @override
//   _LoginAccountState createState() => _LoginAccountState();
// }
//
// class _LoginAccountState extends State<LoginAccount> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _captchaController = TextEditingController();
//   String randomString = "";
//   bool isVerified = false;
//
//
//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       isVerified = _captchaController.text == randomString;
//       if (!isVerified) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Please verify the captcha.")));
//         return;
//       }
//
//       final String email = _emailController.text.trim();
//       final String password = _passwordController.text.trim();
//
//       try {
//         final response = await http.post(
//           Uri.parse('http://${NetworkConfig().ipAddress}:5000/login'),
//           headers: {'Content-Type': 'application/json; charset=UTF-8'},
//           body: jsonEncode({'email': email, 'password': password}),
//         );
//
//         final data = jsonDecode(response.body);
//         if (response.statusCode == 200) {
//           final int role = data['role'];
//           final int userId = data['user_id'];
//
//
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setBool('isLoggedIn', true);
//           await prefs.setInt('userId', userId);
//           await prefs.setInt('role', role);
//
//           switch (role) {
//             case 0:
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => AdminHomeScreen()));
//               break;
//             case 1:
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => HomeScreen()));
//               break;
//             case 2:
//               Navigator.pushReplacement(
//                   context, MaterialPageRoute(builder: (context) => GuestPage()));
//               break;
//             default:
//               ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Invalid role assigned.")));
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(data['message'])));
//         }
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to connect to the server.")));
//       }
//     }
//   }
//
//   void buildCaptcha() {
//     const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
//     const length = 6;
//     final random = Random();
//     randomString = String.fromCharCodes(List.generate(
//         length, (index) => letters.codeUnitAt(random.nextInt(letters.length))));
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     buildCaptcha();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size screenSize = MediaQuery.of(context).size;
//     final double screenHeight = screenSize.height;
//     final double screenWidth = screenSize.width;
//
//     return Scaffold(
//       appBar: null,
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Text(
//                       "Sign In",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.065,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.002),
//                   Center(
//                     child: Text(
//                       "Hi! Welcome back, you've been missed!",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.035,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.025),
//                   _buildInputField(
//                     label: "Email",
//                     hint: "Enter your email",
//                     controller: _emailController,
//                     validator: _validateEmail,
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   _buildPasswordField(
//                     label: "Password",
//                     hint: "Enter your password",
//                     controller: _passwordController,
//                     validator: _validatePassword,
//                     screenWidth: screenWidth,
//                     screenHeight: screenHeight,
//                   ),
//                   //SizedBox(height: screenHeight * 0.02),
//                   _buildCaptchaSection(screenWidth: screenWidth, screenHeight: screenHeight),
//                   SizedBox(height: screenHeight * 0.02),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _login,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Text(
//                           "Sign In",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: screenWidth * 0.05,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Don't have an account? ",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.04,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccountScreen()));
//                         },
//                         child: Text(
//                           "Sign Up",
//                           style: TextStyle(
//                             color: AppColors.primaryColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: screenWidth * 0.035,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInputField({
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//     required double screenWidth,
//     required double screenHeight,
//     required String? Function(String?) validator,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(height: screenHeight * 0.005),
//           TextFormField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: hint,
//               border: OutlineInputBorder(),
//             ),
//             validator: validator,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPasswordField({
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//     required double screenWidth,
//     required double screenHeight,
//     required String? Function(String?) validator,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(height: screenHeight * 0.005),
//           TextFormField(
//             controller: controller,
//             obscureText: true,
//             decoration: InputDecoration(
//               hintText: hint,
//               border: OutlineInputBorder(),
//             ),
//             validator: validator,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCaptchaSection({
//     required double screenWidth,
//     required double screenHeight,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Captcha", style: TextStyle(fontWeight: FontWeight.bold)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(border: Border.all(width: screenWidth*0.002), borderRadius: BorderRadius.circular(8)),
//                   child: Text(randomString, style: TextStyle(fontWeight: FontWeight.w500)),
//                 ),
//               ),
//               IconButton(onPressed: buildCaptcha, icon: Icon(Icons.refresh))
//             ],
//           ),
//           SizedBox(height: screenHeight * 0.02),
//           Text("Enter the captcha value", style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(height: screenHeight * 0.005),
//           TextFormField(
//             controller: _captchaController,
//             decoration: InputDecoration(hintText: "Enter Captcha Value", border: OutlineInputBorder()),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Email is required.";
//     }
//     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//       return "Invalid email format.";
//     }
//     return null;
//   }
//
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Password is required.";
//     }
//     if (value.length < 8) {
//       return "Password must be at least 8 characters long.";
//     }
//     return null;
//   }
// }
//
// // Example Pages for Different Roles
// class GuestPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Guest Page")),
//       body: Center(child: Text("Welcome, Guest!")),
//     );
//   }
// }
//

import 'dart:math';

import 'package:family_wear_app/1_Auth/Intro/2_Create_Account_Page/register_page.dart';
import 'package:family_wear_app/6_Customer/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../../../5_Admin/1_AdminHomeScreen.dart';
import '../../../6_Customer/1_MainScreen/Cart_Screen/Cart_provider.dart';
import '../../../6_Customer/2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../../../ip_address.dart';

class LoginAccount extends StatefulWidget {
  @override
  _LoginAccountState createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  String randomString = "";
  bool isVerified = false;
  bool _isLoading = false;


  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     isVerified = _captchaController.text == randomString;
  //     if (!isVerified) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Please verify the captcha.")));
  //       return;
  //     }
  //
  //     setState(() => _isLoading = true);
  //
  //     final String email = _emailController.text.trim();
  //     final String password = _passwordController.text.trim();
  //
  //     try {
  //       final response = await http.post(
  //         Uri.parse('http://${NetworkConfig().ipAddress}:5000/login'),
  //         headers: {'Content-Type': 'application/json; charset=UTF-8'},
  //         body: jsonEncode({'email': email, 'password': password}),
  //       );
  //
  //       final data = jsonDecode(response.body);
  //       if (response.statusCode == 200) {
  //         final int role = data['role'];
  //         final int userId = data['user_id'];
  //         final String userName = data['user_name'] ?? "";
  //         final String userEmail = data['email'] ?? email;
  //         final String imageUrl = data['user_image'] ?? "";
  //
  //         // Store user data in provider
  //         final userProvider = Provider.of<UserProvider>(context, listen: false);
  //         await userProvider.setUserData(
  //           userId,
  //           role,
  //           userName,
  //           userEmail,
  //           imageUrl, // Add image URL
  //         );
  //
  //         // If additional data is needed, fetch complete user profile
  //         if (userName.isEmpty || imageUrl.isEmpty) {
  //           try {
  //             final userResponse = await http.post(
  //               Uri.parse('http://${NetworkConfig().ipAddress}:5000/user'),
  //               headers: {'Content-Type': 'application/json'},
  //               body: jsonEncode({'user_id': userId}),
  //             );
  //
  //             if (userResponse.statusCode == 200) {
  //               final userData = jsonDecode(userResponse.body);
  //               await userProvider.setUserData(
  //                 userId,
  //                 role,
  //                 userData['user_name'] ?? userName,
  //                 userData['email'] ?? userEmail,
  //                 userData['user_image'] ?? imageUrl,
  //               );
  //             }
  //           } catch (e) {
  //             print("Error fetching additional user details: $e");
  //           }
  //         }
  //
  //         // Navigate based on role
  //         switch (role) {
  //           case 0:
  //             Navigator.pushReplacement(context,
  //                 MaterialPageRoute(builder: (context) => AdminHomeScreen()));
  //             break;
  //           case 1:
  //             Navigator.pushReplacement(context,
  //                 MaterialPageRoute(builder: (context) => HomeScreen()));
  //             break;
  //           case 2:
  //             Navigator.pushReplacement(context,
  //                 MaterialPageRoute(builder: (context) => GuestPage()));
  //             break;
  //           default:
  //             ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(content: Text("Invalid role assigned.")));
  //         }
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text(data['message'])));
  //       }
  //     } catch (error) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Failed to connect to the server.")));
  //     } finally {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      isVerified = _captchaController.text == randomString;
      if (!isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please verify the captcha.")));
        return;
      }

      setState(() => _isLoading = true);

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        final response = await http.post(
          Uri.parse('http://${NetworkConfig().ipAddress}:5000/login'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({'email': email, 'password': password}),
        );

        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          final int role = data['role'];
          final int userId = data['user_id'];
          final String userName = data['user_name'] ?? "";
          final String userEmail = data['email'] ?? email;
          final String imageUrl = data['user_image'] ?? "";

          final userProvider = Provider.of<UserProvider>(context, listen: false);
          await userProvider.setUserData(
            userId,
            role,
            userName,
            userEmail,
            imageUrl,
          );

          // If additional data is needed, fetch complete user profile
          if (userName.isEmpty || imageUrl.isEmpty) {
            try {
              final userResponse = await http.post(
                Uri.parse('http://${NetworkConfig().ipAddress}:5000/user'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'user_id': userId}),
              );

              if (userResponse.statusCode == 200) {
                final userData = jsonDecode(userResponse.body);
                await userProvider.setUserData(
                  userId,
                  role,
                  userData['user_name'] ?? userName,
                  userData['email'] ?? userEmail,
                  userData['user_image'] ?? imageUrl,
                );
              }
            } catch (e) {
              print("Error fetching additional user details: $e");
            }
          }

          // ✅ Initialize cart after login success
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          await cartProvider.initialize(userId.toString());

          // Navigate based on role
          switch (role) {
            case 0:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AdminHomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
              break;
            case 2:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => GuestPage()));
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Invalid role assigned.")));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to connect to the server.")));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  void buildCaptcha() {
    const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    const length = 6;
    final random = Random();
    randomString = String.fromCharCodes(List.generate(
        length, (index) => letters.codeUnitAt(random.nextInt(letters.length))));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    buildCaptcha();
    // // Then when user logs in:
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final cartProvider = Provider.of<CartProvider>(context, listen: false);
    // cartProvider.initialize(userProvider.userId.toString());
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      appBar: null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.002),
                  Center(
                    child: Text(
                      "Hi! Welcome back, you've been missed!",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  _buildInputField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: _emailController,
                    validator: _validateEmail,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  _buildPasswordField(
                    label: "Password",
                    hint: "Enter your password",
                    controller: _passwordController,
                    validator: _validatePassword,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  _buildCaptchaSection(screenWidth: screenWidth, screenHeight: screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccountScreen()));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required double screenWidth,
    required double screenHeight,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.005),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required double screenWidth,
    required double screenHeight,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.005),
          TextFormField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildCaptchaSection({
    required double screenWidth,
    required double screenHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Captcha", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(width: screenWidth*0.002), borderRadius: BorderRadius.circular(8)),
                  child: Text(randomString, style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
              IconButton(onPressed: buildCaptcha, icon: Icon(Icons.refresh))
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text("Enter the captcha value", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.005),
          TextFormField(
            controller: _captchaController,
            decoration: InputDecoration(hintText: "Enter Captcha Value", border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Invalid email format.";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required.";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long.";
    }
    return null;
  }
}

// Example Pages for Different Roles
class GuestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guest Page")),
      body: Center(child: Text("Welcome, Guest!")),
    );
  }
}

