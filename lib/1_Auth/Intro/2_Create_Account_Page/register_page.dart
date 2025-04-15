import
'package:family_wear_app/1_Auth/Intro/2_Create_Account_Page/Login_Account.dart';
import 'package:family_wear_app/1_Auth/Intro/2_Create_Account_Page/Profile_Page.dart';
import 'package:family_wear_app/1_Auth/Intro/2_Create_Account_Page/termAndConditions_Page.dart';
import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../raaf_Page.dart';
import '../Intro_Providers/Create_Account_Provider.dart';

// Second Screen
class CreateAccountScreen extends StatefulWidget {
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getToken(context);
  }

  Future<void> getToken(BuildContext context) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null) {
        Provider.of<CreateAccountProvider>(context, listen: false).setDeviceToken(token);
      } else {
        debugPrint("Token is null");
      }
    } catch (e) {
      debugPrint("Failed to retrieve device token: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: null,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //SizedBox(height: screenHeight * 0.11),

                  // Title
                  Center(
                    child: Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.002),

                  // Subtitle
                  Center(
                    child: Text(
                      "Fill your information below or register \nwith your social account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),

                  // Input Fields
                  _buildInputField(
                    label: "Name",
                    hint: "Ex. John Doe",
                    validator: _validateName,
                    onChanged: (value) {
                      Provider.of<CreateAccountProvider>(context, listen: false).setName(value);
                    },
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),

                  // Email
                  _buildInputField(
                    label: "Email",
                    hint: "example@gmail.com",
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    onChanged: (value) {
                      Provider.of<CreateAccountProvider>(context, listen: false).setEmail(value);
                    },
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),


                  Consumer<CreateAccountProvider>(
                    builder: (context, provider, child) {
                      return _buildPasswordField(
                        label: "Password",
                        hint: "Enter Password",
                        isVisible: provider.isPasswordVisible1,
                        toggleVisibility: provider.togglePasswordVisibility1,
                        validator: _validatePassword,
                        onChanged: provider.setPassword,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      );
                    },
                  ),

                  Consumer<CreateAccountProvider>(
                    builder: (context, provider, child) {
                      return _buildPasswordField(
                        label: "Confirm Password",
                        hint: "Enter Confirm Password",
                        isVisible: provider.isPasswordVisible2,
                        toggleVisibility: provider.togglePasswordVisibility2,
                        validator: _validatePassword,
                        onChanged: provider.setPassword,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      );
                    },
                  ),

                  // Terms & Conditions
                  /*Consumer<CreateAccountProvider>(
                    builder: (context, provider, child) {
                      return _buildTermsAndConditions(context, screenWidth, screenHeight, provider);
                    },
                  ),*/
                  TermsAndConditionsPage(screenWidth: screenWidth, screenHeight: screenHeight,),

                  // Submit Button
                  SizedBox(height: screenHeight * 0.02),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && Provider.of<CreateAccountProvider>(context, listen: false).isTermsAccepted) {
                          Provider.of<CreateAccountProvider>(context, listen: false).submitForm(context);
                        } else if (!Provider.of<CreateAccountProvider>(context, listen: false).isTermsAccepted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You must accept the Terms & Conditions")),);
                        }

                        // important code for choose admin or user
                        // if (response.statusCode == 201) {
                        //   final responseData = json.decode(response.body);
                        //   final role = responseData['role']; // 'admin' or 'user'
                        //   if (role == 'admin') {
                        //     // Navigate to admin screen
                        //   } else {
                        //     // Navigate to user screen
                        //   }
                        // }

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: isDarkTheme ? AppColors.darkTextColor : AppColors.lightTextColor,
                            fontSize: screenWidth * 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Already have an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginAccount()));
                        },
                        child: Text(
                          "Sign In",
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
    required double screenWidth,
    required double screenHeight,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.005),
          TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: screenHeight * 0.005),
          TextFormField(
            obscureText: !isVisible,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: isVisible ? AppColors.primaryColor : AppColors.darkBackgroundColor.withOpacity(0.8),
                ),
                onPressed: toggleVisibility,
              ),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(BuildContext context, double screenWidth, double screenHeight, CreateAccountProvider provider) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Checkbox(
          checkColor: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkBackgroundColor,
          activeColor: AppColors.primaryColor,
          value: provider.isTermsAccepted,
          onChanged: (value) => provider.setTermsAccepted(value!),
        ),
        const Text("Agree with "),
        GestureDetector(
          onTap: () {
            // Directly pass `context` to the modal bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return SafeArea(
                  // Added SafeArea to avoid overlap with system bars
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.04),

                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Terms and Conditions",
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor, // Dynamic color
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                              color: isDarkTheme ? AppColors.lightTextColor : AppColors.darkTextColor, // Dynamic color
                            ),
                          ],
                        ),
                        //const Divider(thickness: 1, color: Colors.grey),

                        // Content Section
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Terms Header
                                  Text(
                                    "Terms and Responsibilities for Users",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkTheme ? AppColors.lightTextColor.withOpacity(0.9) : AppColors.darkTextColor, // Dynamic color
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),

                                  // Description
                                  Text(
                                    "Welcome to the Family Ware Shopping App! By using our platform, you agree to the following terms and responsibilities, designed to ensure a safe, trustworthy, and enjoyable shopping experience for everyone.",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: isDarkTheme ? AppColors.lightTextColor.withOpacity(0.7) : AppColors.darkTextColor, // Dynamic color
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),

                                  // List of Terms
                                  _buildTermsList(context, screenWidth, screenHeight),

                                  // End Message
                                  SizedBox(height: screenHeight * 0.01),
                                  Center(
                                    child: Text(
                                      "Thank you for trusting Family Ware Shopping App!",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkTheme ? AppColors.lightTextColor : AppColors.primaryColor, // Dynamic color
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Close Button
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                AppColors.primaryColor, // Dynamic color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.01),
                              ),
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  color: isDarkTheme
                                      ? AppColors.darkTextColor
                                      : AppColors.lightTextColor,
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Text(
            "Terms & Conditions",
            style: TextStyle(
              color: AppColors.primaryColor, // Dynamic color
              //decoration: TextDecoration.underline,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsList(BuildContext context, double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTermItem(
          context,
          "1. Accurate Account Information",
          screenWidth,
          screenHeight,
          "• Users are responsible for providing valid and accurate personal details during registration.\n"
              "• Ensure that your email, phone number, and delivery address are up-to-date to receive notifications and products on time.\n"
              "• Maintain the confidentiality of your account credentials. You are responsible for activities conducted under your account.",
        ),
        _buildTermItem(
          context,
          "2. Family-Friendly Conduct",
          screenWidth,
          screenHeight,
          "• The Family Ware Shopping App promotes a respectful and inclusive community. Any form of offensive language, abusive behavior, or violation of others' rights will result in account suspension.\n"
              "• User reviews and comments must remain constructive and respectful. Inappropriate content may be removed without notice.",
        ),
        _buildTermItem(
          context,
          "3. Secure Transactions",
          screenWidth,
          screenHeight,
          "• We use advanced encryption technologies to protect your payment and personal information.\n"
              "• Users are encouraged to verify the details of transactions, products, and offers before completing a purchase.\n"
              "• Report any suspicious activity or unauthorized charges immediately via our customer support.",
        ),
        _buildTermItem(
          context,
          "4. Order and Delivery Policies",
          screenWidth,
          screenHeight,
          "• Delivery timelines are provided as estimates. While we strive to meet deadlines, unforeseen circumstances may occasionally cause delays.\n"
              "• Users are responsible for inspecting the product upon delivery. If there are any issues (e.g., damaged or incorrect items), report them within 48 hours to qualify for returns or exchanges.",
        ),
        _buildTermItem(
          context,
          "5. Return and Refund Policies",
          screenWidth,
          screenHeight,
          "• Users may initiate returns for eligible products within the specified return period. Please refer to the product description for return eligibility.\n"
              "• Refunds are processed promptly once the returned product is received and verified. Ensure your bank details are accurate for smooth transactions.",
        ),
        _buildTermItem(
          context,
          "6. Privacy and Data Security",
          screenWidth,
          screenHeight,
          "• We prioritize user privacy. Your personal data will not be shared with third parties without your consent, except as required by law.\n"
              "• The app may collect data to improve services, including preferences and shopping habits. This data is anonymized and secure.",
        ),
        _buildTermItem(
          context,
          "7. Compliance with Local Laws",
          screenWidth,
          screenHeight,
          "• Users must adhere to the applicable laws and regulations in their region when using the app.\n"
              "• Products purchased should only be used as intended and in accordance with the law.",
        ),
        _buildTermItem(
          context,
          "8. Commitment to Transparency",
          screenWidth,
          screenHeight,
          "• We are committed to maintaining transparency in all transactions, promotions, and policies.\n"
              "• Users can contact our support team for any clarifications or concerns. We value your feedback and aim to resolve issues promptly.",
        ),
      ],
    );
  }

  Widget _buildTermItem(BuildContext context, String title, double screenWidth, double screenHeight, String content) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? AppColors.lightTextColor.withOpacity(0.9) : AppColors.darkTextColor,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            content,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: isDarkTheme ? AppColors.lightTextColor.withOpacity(0.7) : AppColors.darkTextColor,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required.";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required.";
    }
    if (!RegExp(r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
        .hasMatch(value)) {
      return "Enter a valid email address.";
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
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must include at least one uppercase letter.";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must include at least one number.";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must include at least one special character.";
    }
    return null;
  }

}


