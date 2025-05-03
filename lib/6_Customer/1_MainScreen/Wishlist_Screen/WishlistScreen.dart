import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../../../5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../../2_CustomerProviders/Item_Provider.dart';
import '../Cart_Screen/Cart_provider.dart';
import '../Home_Tab_Screen/HomeTabScreen.dart';

// class WishlistScreen extends StatelessWidget {
//
//   const WishlistScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkTheme = theme.brightness == Brightness.dark;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final items = Provider.of<ItemProvider>(context).items;
//
//
//
//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
//                   child: Text("WishList Products",
//                   style: TextStyle(
//                     fontSize: screenHeight * 0.025,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   ),
//                 ),
//                 LayoutBuilder(
//                 builder: (context, constraints) {
//                   int crossAxisCount = (constraints.maxWidth / 180).floor();
//                   double aspectRatio = screenWidth < 400 ? 2 / 3 : 3 / 4;
//                   return GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: items.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: crossAxisCount > 1 ? crossAxisCount : 2,
//                       //crossAxisCount: 2,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       //childAspectRatio: 3 / 4,
//                       childAspectRatio: aspectRatio,
//                     ),
//                     itemBuilder: (context, index) {
//                       final item = items[index];
//                       return Stack(
//                         children: [
//
//                           Card(
//                             elevation: 4,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Image Section
//                                 Stack(
//                                   children: [
//                                     Container(
//                                       height: screenHeight * 0.2,
//                                       decoration: BoxDecoration(
//                                         borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(12),
//                                           topRight: Radius.circular(12),
//                                         ),
//                                         image: DecorationImage(
//                                           image: AssetImage(item.image),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                     // Optional: Add a gradient overlay for text readability
//                                     Positioned.fill(
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius: const BorderRadius.only(
//                                             topLeft: Radius.circular(12),
//                                             topRight: Radius.circular(12),
//                                           ),
//                                           gradient: LinearGradient(
//                                             colors: [
//                                               Colors.black.withOpacity(0.2),
//                                               Colors.black.withOpacity(0.0),
//                                             ],
//                                             begin: Alignment.topCenter,
//                                             end: Alignment.bottomCenter,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       // Row for Name and Price
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           // Item Name
//                                           Expanded(
//                                             child: AutoSizeText(
//                                               item.name,
//                                               overflow: TextOverflow.ellipsis,
//                                               // Handle text overflow
//                                               maxLines: 1,
//                                               // Limit to a single line
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: screenHeight * 0.018,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(height: screenHeight * 0.01),
//                                           // Price
//                                           Text(
//                                             item.price,
//                                             textAlign: TextAlign.right,
//                                             style: TextStyle(
//                                               color: Colors.green,
//                                               fontSize: screenHeight * 0.016,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: screenHeight * 0.001),
//                                       // Item Description
//                                       AutoSizeText(
//                                         item.description,
//                                         overflow: TextOverflow.ellipsis,
//                                         // Handle text overflow
//                                         maxLines: 1,
//                                         // Limit description to 2 lines
//                                         style: TextStyle(
//                                           color: Colors.grey,
//                                           fontSize: screenHeight * 0.015,
//                                         ),
//                                       ),
//
//                                       SizedBox(height: screenHeight * 0.005),
//                                       // Row for Item Sold and Rating
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           // Sold Items
//                                           Text(
//                                             '${item.soldItem} Sold',
//                                             overflow: TextOverflow.ellipsis,
//                                             maxLines: 1,
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               color: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkTextColor,
//                                               fontSize: screenHeight * 0.015,
//                                             ),
//                                           ),
//
//                                           // Rating Stars
//                                           Row(
//                                             children: List.generate(5, (index) {
//                                               if (index < item.rating.floor()) {
//                                                 // Full star
//                                                 return Icon(
//                                                   Icons.star,
//                                                   color: Colors.orange,
//                                                   size: screenHeight * 0.02,
//                                                 );
//                                               } else if (index < item.rating) {
//                                                 // Half star
//                                                 return Icon(
//                                                   Icons.star_half,
//                                                   color: Colors.orange,
//                                                   size: screenHeight * 0.02,
//                                                 );
//                                               } else {
//                                                 // Empty star
//                                                 return Icon(
//                                                   Icons.star_border,
//                                                   color: Colors.orange,
//                                                   size: screenHeight * 0.02,
//                                                 );
//                                               }
//                                             }),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // Favorite Icon with Curved Background and Border
//                           Positioned(
//                             top: 0,
//                             right: 0,
//                             child: Consumer<ItemProvider>(
//                               builder: (context, itemProvider, child) {
//                                 return GestureDetector(
//                                   onTap: () {
//
//                                     // itemProvider.toggleFavorite(index),
//
//                                   },
//                                   // Toggle favorite state
//                                   child: Stack(
//                                     children: [
//                                       // Outer Clip for the Border
//                                       ClipPath(
//                                         clipper: TopRightCurveClipper(),
//                                         child: Container(
//                                           color: Colors.green, // Border color
//                                           padding: const EdgeInsets.all(
//                                               10), // Padding to create a border effect
//                                         ),
//                                       ),
//
//                                       // Inner Clip for the Icon Background
//                                       ClipPath(
//                                         clipper: TopRightCurveClipper(),
//                                         child: Container(
//                                           color: item.isFavorite ? AppColors
//                                               .primaryColor : AppColors
//                                               .lightBackgroundColor,
//                                           // Dynamic background color
//                                           padding: const EdgeInsets.all(8),
//                                           // Padding for the icon
//                                           child: Icon(
//                                             item.isFavorite
//                                                 ? Icons.favorite
//                                                 : Icons.favorite_border,
//                                             color: item.isFavorite ? AppColors
//                                                 .lightBackgroundColor : Colors
//                                                 .black,
//                                             size: screenHeight * 0.03,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
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
        cartProvider.addToCart(userId,itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cartItem.title} added to cart'),
            duration: Duration(seconds: 2),
            // action: SnackBarAction(
            //   label: 'VIEW CART',
            //   onPressed: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => CartScreen()),
            //   ),
            // ),
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
    final itemProvider = Provider.of<ItemProvider>(context);
    final showItemProvider = Provider.of<ShowItemProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final favoriteIds = itemProvider.favoriteItems;

    final favoriteItems = showItemProvider.items
        .where((item) => favoriteIds.contains(item['item_id'].toString()))
        .toList();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  child: Text(
                    "WishList Products",
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth / 180).floor();
                    double aspectRatio = screenWidth < 400 ? 2 / 3.4 : 3 / 4.8;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favoriteItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount > 1 ? crossAxisCount : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final item = favoriteItems[index];
                        final images =
                        (item['item_image'] as List<dynamic>).cast<String>();

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
                                            image: NetworkImage(
                                              images.isNotEmpty
                                                  ? images[0]
                                                  : 'https://via.placeholder.com/150',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: AutoSizeText(
                                                item['item_name'] ?? 'No Name',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: screenHeight * 0.018,
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
                                        SizedBox(height: screenHeight * 0.001),
                                        AutoSizeText(
                                          item['item_description'] ??
                                              'No Description',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: screenHeight * 0.015,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Remaining Quantity: ${item['minimum_qty']}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isDarkTheme
                                                    ? AppColors
                                                    .lightBackgroundColor
                                                    : AppColors.darkTextColor,
                                                fontSize: screenHeight * 0.012,
                                              ),
                                            ),
                                            // Row(
                                            //   children: List.generate(5, (starIndex) {
                                            //     return Icon(
                                            //       Icons.star,
                                            //       color: Colors.orange,
                                            //       size: screenHeight * 0.02,
                                            //     );
                                            //   }),
                                            // ),
                                          ],
                                        ),
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
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Consumer<ItemProvider>(
                                builder: (context, itemProvider, child) {
                                  final itemId = item['item_id'].toString();
                                  final isFavorite = itemProvider.favoriteItems
                                      .contains(itemId);

                                  return GestureDetector(
                                    onTap: () => itemProvider.toggleFavorite(
                                      itemId,
                                      userProvider.userId.toString(),
                                    ),
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
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
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
                        );
                      },
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
}
