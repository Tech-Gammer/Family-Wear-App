  import 'dart:convert';
  import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
  import 'package:carousel_slider/carousel_slider.dart';
  import 'package:flutter/material.dart';
  import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
  import 'package:provider/provider.dart';
  import '../../../5_Admin/AdminHomePages/Slider_Management/showSlider_Provider.dart';
  import '../../../ip_address.dart';
  import '../../2_CustomerProviders/Category_Provider.dart';
  import '../../2_CustomerProviders/HomeScrollProvider.dart';
  import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
  import '../../2_CustomerProviders/Item_Provider.dart';
  import '../../2_CustomerProviders/Search_Provider.dart';
  import '../Cart_Screen/CartScreen.dart';
  import '../Cart_Screen/Cart_provider.dart';
  import '../Cart_Screen/item_GeneralCard.dart';
  import 'package:http/http.dart' as http;

  import 'Item_Detail_Screen.dart';


  class HomeTabScreen extends StatefulWidget {
    const HomeTabScreen({super.key});

    @override
    State<HomeTabScreen> createState() => _HomeTabScreenState();
  }

  class _HomeTabScreenState extends State<HomeTabScreen> {
    int? userId;
    late PageController _pageController;
    @override
    void initState() {
      super.initState();
      _pageController = PageController(viewportFraction: 0.85);

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userId = userProvider.userId;

        // Load initial data without triggering rebuild
        await userProvider.loadUserDataFromPrefs();

        if (userId != null) {
          await userProvider.fetchUserData();
        }

        // Load other providers
        final showSliderProvider = Provider.of<ShowSliderProvider>(context, listen: false);
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        final showItemProvider = Provider.of<ShowItemProvider>(context, listen: false);
        final itemProvider = Provider.of<ItemProvider>(context, listen: false);

        // Schedule provider initializations
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSliderProvider.fetchSliderImages();
          categoryProvider.fetchCategories();
          showItemProvider.fetchItems();
          itemProvider.loadFavorites(userId?.toString() ?? '');
        });
      });
    }



    void _addToCart(BuildContext context, dynamic itemData) async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      String userId = userProvider.userId.toString();
      String itemId = itemData['item_id'].toString();

      // Prepare cart item data
      Map<String, dynamic> item = {};
      itemData.forEach((key, value) {
        item[key.toString()] = value;
      });

      List<dynamic> imageList = [];
      if (item['item_image'] != null && item['item_image'] is List) {
        imageList = item['item_image'];
      }

      final cartItem = CartItem(
        userId: userId,
        itemId: itemId,
        title: item['item_name']?.toString() ?? 'Unknown Item',
        category: item['category_id']?.toString() ?? '0',
        price: double.tryParse(item['net_price']?.toString() ?? '0.0') ?? 0.0,
        imageUrl: imageList.isNotEmpty
            ? 'http://${NetworkConfig().ipAddress}:5000/uploads/${imageList[0]}'
            : 'https://via.placeholder.com/150',
      );

      try {
        bool success = await _addToCartBackend(context, userId, itemId);

        if (success) {
          cartProvider.addToCart(cartItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${cartItem.title} added to cart'),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'VIEW CART',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                ),
              ),
            ),
          );
        }
      } catch (e) {
        print('Exception when adding to cart: $e');
      }
    }

  // New method to handle API call
    Future<bool> _addToCartBackend(BuildContext context, String userId, String itemId) async {
      try {
        final response = await http.post(
          Uri.parse('http://${NetworkConfig().ipAddress}:5000/add-to-cart'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': userId,
            'item_id': itemId,
          }),
        );

        if (response.statusCode == 200) {
          return true;
        } else if (response.statusCode == 400) {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        } else {
          print('Error adding to cart: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add to cart'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
      } catch (e) {
        print('Exception when adding to cart: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error, please try again'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }
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
      // final items = Provider.of<ItemProvider>(context).items;
      final items = Provider.of<ShowItemProvider>(context).items; // Add
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         // CircleAvatar(
                  //         //   radius: screenHeight * 0.03,
                  //         //   backgroundImage: userProvider.imageUrl.isNotEmpty
                  //         //       ? NetworkImage(userProvider.imageUrl)
                  //         //       : AssetImage("asset/wallet.jpg") as ImageProvider,
                  //         // ),
                  //         SizedBox(width: screenWidth * 0.03),
                  //         Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               userProvider.name.isNotEmpty
                  //                   ? userProvider.name
                  //                   : "Guest User",
                  //               style: TextStyle(
                  //                 fontWeight: FontWeight.bold,
                  //                 fontSize: responsiveFontSize * 1.4,
                  //               ),
                  //             ),
                  //             Text(
                  //               "ID: ${userProvider.userId ?? 'N/A'}",
                  //               style: TextStyle(
                  //                 color: Colors.grey,
                  //                 fontSize: responsiveFontSize * 1.1,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //     Container(
                  //       height: screenHeight * 0.05,
                  //       width: screenHeight * 0.05,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: isDarkTheme ? AppColors.accentColor : AppColors.background,
                  //       ),
                  //       child: Icon(
                  //         Icons.notifications,
                  //         size: responsiveFontSize * 2,
                  //         color: AppColors.primaryColor,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      if (userProvider.isLoading) {
                        return LinearProgressIndicator();
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // CircleAvatar(
                              //   radius: screenHeight * 0.03,
                              //   backgroundImage: userProvider.imageUrl.isNotEmpty
                              //       ? NetworkImage(userProvider.imageUrl)
                              //       : AssetImage("dress.png") as ImageProvider,
                              // ),
                              SizedBox(width: screenWidth * 0.03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userProvider.name.isNotEmpty
                                        ? userProvider.name
                                        : "Guest User",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsiveFontSize * 1.4,
                                    ),
                                  ),
                                  Text(
                                    "ID: ${userProvider.userId ?? 'N/A'}",
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
                      );
                    },
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
                      // childAspectRatio: 2.8/ 4,
                      childAspectRatio: 2.8/ 5, // Adjusted to make room for the button
                    ),
                    itemBuilder: (context, index) {
                      // final item = items[index];
                      final item = Map<String, dynamic>.from(items[index]);
                      final images = (item['item_image'] as List<dynamic>).cast<String>();
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(itemData: item),
                            ),
                          );
                        },
                        child: Stack(
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
                                            image: NetworkImage(
                                                images.isNotEmpty
                                                    ? images[0]
                                                    : 'https://via.placeholder.com/150' // Fallback URL
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      // Gradient Overlay (Optional)
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Name and Price
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['item_name'] ?? 'No Name',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenHeight * 0.016,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${item['net_price']} PKR",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: screenHeight * 0.016,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        // Description
                                        Text(
                                          item['item_description'] ?? 'No Description',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: screenHeight * 0.014,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        // Available Quantity and Rating Stars in the same row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Rating Stars
                                            Row(
                                              children: [
                                                Icon(Icons.star, color: Colors.orange, size: screenHeight * 0.015),
                                                Icon(Icons.star, color: Colors.orange, size: screenHeight * 0.015),
                                                Icon(Icons.star, color: Colors.orange, size: screenHeight * 0.015),
                                                Icon(Icons.star_border, color: Colors.orange, size: screenHeight * 0.015),
                                                Icon(Icons.star_border, color: Colors.orange, size: screenHeight * 0.015),
                                              ],
                                            ),
                                            // Available Quantity
                                            Text(
                                              "${item['minimum_qty']} Available",
                                              style: TextStyle(
                                                fontSize: screenHeight * 0.013,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),

                                        // Add to Cart Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryColor,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              // Call function to add item to cart
                                              _addToCart(context, item);
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart,
                                                  color: Colors.white,
                                                  size: screenHeight * 0.018,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Add to Cart",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: screenHeight * 0.013,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                  final itemId = item['item_id']?.toString() ?? '';
                                  final isFavorite = itemProvider.favoriteItems.contains(itemId);

                                  return GestureDetector(
                                    onTap: () => itemProvider.toggleFavorite(itemId, userId.toString()),
                                    child: Stack(
                                      children: [
                                        ClipPath(
                                          clipper: TopRightCurveClipper(),
                                          child: Container(
                                            color: Colors.green,
                                            padding: const EdgeInsets.all(10),
                                          ),
                                        ),
                                        ClipPath(
                                          clipper: TopRightCurveClipper(),
                                          child: Container(
                                            color: isFavorite
                                                ? AppColors.primaryColor
                                                : AppColors.lightBackgroundColor,
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite
                                                  ? AppColors.lightBackgroundColor
                                                  : Colors.black,
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
                        ),
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
      final path = Path();
      path.moveTo(size.width * 0.7, 0);
      path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.3);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      path.close();
      return path;
    }

    @override
    bool shouldReclip(CustomClipper<Path> oldClipper) => false;
  }