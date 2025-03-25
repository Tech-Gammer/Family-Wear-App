import 'package:flutter/material.dart';
import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:provider/provider.dart';

import '../Intro_Providers/Create_Account_Provider.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const TermsAndConditionsPage({
    required this.screenWidth,
    required this.screenHeight,
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Consumer<CreateAccountProvider>(
      builder: (context, provider, child) {
        return _buildTermsAndConditions(context, screenWidth, screenHeight, provider);
      },
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
}