import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../4_Provider/intro_Provider/First_Three_Provider.dart';
import '../../../4_Provider/statusBarColor_Provider.dart';
import 'third_Screen.dart';
import 'first_Screen.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    //final pageNotifier = Provider.of<PageNotifier>(context);

    // Access the PageNotifier and StatusBarProvider
    final pageNotifier = Provider.of<PageNotifier>(context);
    final statusBarProvider = Provider.of<StatusBarProvider>(context);

    // Update the status bar style dynamically for this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      statusBarProvider.setStatusBar(
        isDarkTheme ? AppColors.darkBackgroundColor : AppColors.lightBackgroundColor,
        isDarkTheme ? Brightness.light : Brightness.dark,
      );
    });

    return Scaffold(
      backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : AppColors.lightBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: PNG Image
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1, vertical: screenHeight * 0.01),
                child: Image.asset(
                  "asset/intro/whisList.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Text Section: Title, Subtitle, and Description
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Wishlist to Dream Product,",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme
                            ? AppColors.lightTextColor
                            : AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "in Just a Few Clicks",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * 0.022,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme
                            ? AppColors.lightTextColor
                            : AppColors.darkTextColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      "Turn your wishlist into reality effortlessly. Save your favorite items, "
                          "track price drops, and purchase your dream products with just a few clicks.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * 0.018,
                        color: isDarkTheme ? Colors.grey : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Section: Previous, Indicator, and Next Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        pageNotifier.previousPage();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FirstScreen()),
                        );
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryColor,
                          size: screenHeight * 0.035,
                        ),
                      ),
                    ),
                  ),

                  // Page Indicator
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        width: screenWidth * 0.03,
                        height: screenWidth * 0.03,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pageNotifier.currentPage == index ? AppColors.primaryColor : (isDarkTheme ? Colors.grey[600] : Colors.grey[300]),
                        ),
                      );
                    }),
                  ),

                  // Next Button
                  Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        pageNotifier.nextPage();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ThirdScreen()));
                      },
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: screenHeight * 0.035,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
