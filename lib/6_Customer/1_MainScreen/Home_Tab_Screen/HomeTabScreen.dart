import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:provider/provider.dart';
import '../../../5_Admin/AdminHomePages/Slider_Management/showSlider_Provider.dart';
import '../../2_CustomerProviders/Category_Provider.dart';
import '../../2_CustomerProviders/HomeScrollProvider.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../../2_CustomerProviders/Item_Provider.dart';
import '../../2_CustomerProviders/Search_Provider.dart';
import '../Cart_Screen/item_GeneralCard.dart';

class HomeTabScreen extends StatefulWidget {
  HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {

  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShowSliderProvider>(context, listen: false).fetchSliderImages();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final searchProvider = Provider.of<SearchProvider>(context);
    final scrollProvider = Provider.of<HorizontalScrollProvider>(context);
    final PageController pageController = PageController(viewportFraction: 0.85);
    final categories = Provider.of<CategoryProvider>(context).categories;
    final items = Provider.of<ItemProvider>(context).items;
    final userProvider = Provider.of<UserProvider>(context);
    final sliderProvider = Provider.of<ShowSliderProvider>(context);


    double baseFontSize = 11;
    double responsiveFontSize = baseFontSize * (screenWidth / 375);

    return Scaffold(
      backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : AppColors.lightBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView( // Make the layout scrollable
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header Section: Profile and Notification Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: screenHeight * 0.03,
                          //backgroundImage: AssetImage("asset/sufyan.jpg"),
                          backgroundImage: userProvider.imageUrl.isNotEmpty
                              ? NetworkImage(userProvider.imageUrl)
                              : AssetImage("asset/wallet.jpg") as ImageProvider,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Muhammad Sufyan",
                              //userProvider.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: responsiveFontSize * 1.4,
                              ),
                            ),
                            Text(
                              "user_id",
                              //userProvider.email,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: responsiveFontSize * 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: screenHeight * 0.05,
                      width: screenHeight * 0.05,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkTheme ? AppColors.accentColor : AppColors.background,
                      ),
                      child: Icon(
                        Icons.notifications,
                        size: responsiveFontSize * 2,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                // Search Bar
                Container(
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: isDarkTheme ? AppColors.accentColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                        child: Icon(
                          Icons.search,
                          color: AppColors.primaryColor,
                          size: responsiveFontSize * 2,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => searchProvider.userStartedTyping(),
                          onTap: () => searchProvider.userStartedTyping(),
                          onEditingComplete: () => searchProvider.userStoppedTyping(),
                          decoration: InputDecoration(
                            hintText: searchProvider.currentPlaceholder,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: responsiveFontSize,
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: responsiveFontSize),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade300,
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                        child: Icon(
                          Icons.filter_list_alt,
                          color: AppColors.primaryColor,
                          size: responsiveFontSize * 2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.015),

                // Horizontal Scrollable Banner
                Text(
                  "Special For You",
                  style: TextStyle(
                    fontSize: responsiveFontSize * 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),

                // CarouselSlider(
                //   options: CarouselOptions(
                //     height: screenHeight * 0.2,
                //     aspectRatio: 16/9,
                //     viewportFraction: 0.85,
                //     autoPlay: true,
                //     onPageChanged: (index, reason) {
                //       Provider.of<HorizontalScrollProvider>(context, listen: false)
                //           .updatePage(index);
                //     },
                //   ),
                //   items: images.map((image) {
                //     return Builder(
                //       builder: (BuildContext context) {
                //         return Container(
                //           margin: EdgeInsets.symmetric(horizontal: 8.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(12),
                //             image: DecorationImage(
                //               image: AssetImage(image),
                //               fit: BoxFit.cover,
                //             ),
                //           ),
                //         );
                //       },
                //     );
                //   }).toList(),
                // ),
                // SizedBox(height: screenHeight * 0.01),
                // // Dots Indicator
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: List.generate(images.length, (index) {
                //     return AnimatedContainer(
                //       duration: const Duration(milliseconds: 300),
                //       margin: const EdgeInsets.symmetric(horizontal: 4.0),
                //       height: 8,
                //       width: scrollProvider.currentPage == index ? 16 : 8,
                //       decoration: BoxDecoration(
                //         color: scrollProvider.currentPage == index
                //             ? AppColors.primaryColor
                //             : Colors.grey,
                //         borderRadius: BorderRadius.circular(4),
                //       ),
                //     );
                //   }),
                // ),
                _buildImageSlider(screenHeight, sliderProvider, scrollProvider),


                SizedBox(height: screenHeight * 0.005),

                // Categories Section
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: responsiveFontSize * 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: screenHeight * 0.015),

                // SizedBox(
                //   height: screenHeight * 0.12,
                //   child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: categories.length,
                //     itemBuilder: (context, index) {
                //       final category = categories[index];
                //       return Padding(
                //         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                //         child: Column(
                //           children: [
                //             Container(
                //               height: screenHeight * 0.07,
                //               width: screenHeight * 0.07,
                //               decoration: BoxDecoration(
                //                 shape: BoxShape.rectangle,
                //                 borderRadius: BorderRadius.circular(10),
                //                 image: DecorationImage(
                //                   image: AssetImage(category.icon),
                //                   fit: BoxFit.cover,
                //                 ),
                //               ),
                //             ),
                //
                //             /*Container(
                //               height: screenHeight * 0.07,
                //               width: screenHeight * 0.07,
                //               decoration: BoxDecoration(
                //                 shape: BoxShape.circle,
                //                 image: DecorationImage(
                //                   image: AssetImage(category.icon),
                //                   fit: BoxFit.cover,
                //                 ),
                //               ),
                //             ),*/
                //
                //             SizedBox(height: screenHeight * 0.005),
                //             Text(
                //               category.name,
                //               style: TextStyle(fontSize: screenHeight * 0.015),
                //             ),
                //           ],
                //         ),
                //       );
                //     },
                //   ),
                // ),
                //SizedBox(height: screenHeight * 0.0),

                // Items Section
                // Update the categories section in build()
                Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, _) {
                    if (categoryProvider.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (categoryProvider.error.isNotEmpty) {
                      return Center(child: Text('Error: ${categoryProvider.error}'));
                    }

                    return SizedBox(
                      height: screenHeight * 0.12,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
                            child: Column(
                              children: [
                                Container(
                                  height: screenHeight * 0.07,
                                  width: screenHeight * 0.07,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: category.imageBytes.isNotEmpty
                                          ? MemoryImage(category.imageBytes)
                                          : AssetImage("asset/placeholder.png") as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  category.name,
                                  style: TextStyle(fontSize: screenHeight * 0.015),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Text(
                  "Popular Items",
                  style: TextStyle(
                    fontSize: responsiveFontSize * 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Stack(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Section
                              Stack(
                                children: [
                                  Container(
                                    height: screenHeight * 0.2,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(item.image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Optional: Add a gradient overlay for text readability
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.2),
                                            Colors.black.withOpacity(0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row for Name and Price
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Item Name
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            overflow: TextOverflow.ellipsis, // Handle text overflow
                                            maxLines: 1, // Limit to a single line
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenHeight * 0.015,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        // Price
                                        Text(
                                          item.price,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: screenHeight * 0.015,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.0005),
                                    // Item Description
                                    Text(
                                      item.description,
                                      overflow: TextOverflow.ellipsis, // Handle text overflow
                                      maxLines: 1, // Limit description to 2 lines
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenHeight * 0.015,
                                      ),
                                    ),

                                    SizedBox(height: screenHeight * 0.0005),
                                    // Row for Item Sold and Rating
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Sold Items
                                        Text(
                                          '${item.soldItem} Sold',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkTextColor,
                                            fontSize: screenHeight * 0.01,
                                          ),
                                        ),

                                        // Rating Stars
                                        Row(
                                          children: List.generate(5, (index) {
                                            if (index < item.rating.floor()) {
                                              // Full star
                                              return Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                                size: screenHeight * 0.015,
                                              );
                                            } else if (index < item.rating) {
                                              // Half star
                                              return Icon(
                                                Icons.star_half,
                                                color: Colors.orange,
                                                size: screenHeight * 0.015,
                                              );
                                            } else {
                                              // Empty star
                                              return Icon(
                                                Icons.star_border,
                                                color: Colors.orange,
                                                size: screenHeight * 0.015,
                                              );
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Favorite Icon with Curved Background and Border
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Consumer<ItemProvider>(
                            builder: (context, itemProvider, child) {
                              return GestureDetector(
                                onTap: () => itemProvider.toggleFavorite(index), // Toggle favorite state
                                child: Stack(
                                  children: [
                                    // Outer Clip for the Border
                                    ClipPath(
                                      clipper: TopRightCurveClipper(),
                                      child: Container(
                                        color: Colors.green, // Border color
                                        padding: const EdgeInsets.all(10), // Padding to create a border effect
                                      ),
                                    ),

                                    // Inner Clip for the Icon Background
                                    ClipPath(
                                      clipper: TopRightCurveClipper(),
                                      child: Container(
                                        color: item.isFavorite ? AppColors.primaryColor : AppColors.lightBackgroundColor, // Dynamic background color
                                        padding: const EdgeInsets.all(8), // Padding for the icon
                                        child: Icon(
                                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: item.isFavorite ? AppColors.lightBackgroundColor : Colors.black,
                                          size: screenHeight * 0.03,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
  Widget _buildImageSlider(double screenHeight, ShowSliderProvider sliderProvider, HorizontalScrollProvider scrollProvider) {
    return Column(
      children: [
        // Slider Container
        SizedBox(
          height: screenHeight * 0.2,
          child: sliderProvider.sliderImages.isEmpty
              ? Center(child: CircularProgressIndicator()) // Loading state
              : CarouselSlider(
            options: CarouselOptions(
              height: screenHeight * 0.2,
              aspectRatio: 16 / 9,
              viewportFraction: 0.85,
              autoPlay: true,
              onPageChanged: (index, reason) {
                scrollProvider.updatePage(index);
              },
            ),
            items: sliderProvider.sliderImages.map((image) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(image['image'])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),

        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliderProvider.sliderImages.length,
                (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8,
                width: scrollProvider.currentPage == index ? 16 : 8,
                decoration: BoxDecoration(
                  color: scrollProvider.currentPage == index
                      ? AppColors.primaryColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }


}


class TopRightCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width - 20, 0); // Straight line to near top-right corner
    path.arcToPoint(
      Offset(size.width, 20), // Arc to create a curve
      radius: Radius.circular(20),
      clockwise: true,
    );
    path.lineTo(size.width, size.height); // Straight line down
    path.lineTo(0, size.height); // Bottom-left corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}