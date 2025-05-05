import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../../2_CustomerProviders/Item_Provider.dart';
import '../Cart_Screen/CartScreen.dart';
import '../Cart_Screen/Cart_provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ItemDetailScreen({super.key, required this.itemData});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _currentImageIndex = 0;
  bool? isActive;

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
    final userProvider = Provider.of<UserProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);
    // final images = (widget.itemData['item_image'] as List<dynamic>).cast<String>();
    // List<String> images = [];
    // if (widget.itemData['item_image'] is List) {
    //   images = (widget.itemData['item_image'] as List).map((e) => e.toString()).toList();
    // } else if (widget.itemData['item_image'] != null) {
    //   images = [widget.itemData['item_image'].toString()];
    // }
    // In build() method
    List<String> images = [];
    if (widget.itemData['item_image'] is List) {
      images = (widget.itemData['item_image'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty) // Filter out empty strings
          .toList();
    } else if (widget.itemData['item_image'] != null) {
      images = [widget.itemData['item_image'].toString()];
    }

// Add fallback for empty image list
    if (images.isEmpty) {
      images.add('placeholder.jpg'); // Add default placeholder
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemData['item_name']),
        actions: [
          Consumer<ItemProvider>(
            builder: (context, provider, _) {
              final itemId = widget.itemData['item_id'].toString();
              final isFavorite = provider.favoriteItems.contains(itemId);

              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () => provider.toggleFavorite(
                    itemId,
                    userProvider.userId.toString()
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(images, screenWidth),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.itemData['net_price']} PKR',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${widget.itemData['minimum_qty']} Available',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.itemData['item_description'] ?? 'No description available',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                  _buildAddToCartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget _buildImageCarousel(List<String> images, double screenWidth) {
  //   return Column(
  //     children: [
  //       CarouselSlider(
  //         options: CarouselOptions(
  //           height: 300,
  //           viewportFraction: 1,
  //           onPageChanged: (index, reason) {
  //             setState(() => _currentImageIndex = index);
  //           },
  //         ),
  //         items: images.map((image) {
  //           final imageUrl = image.startsWith('http')
  //               ? image
  //               : 'http://${NetworkConfig().ipAddress}:5000/uploads/$image';
  //           print("Loading image: $imageUrl");
  //           return Builder(
  //             builder: (context) => Container(
  //               width: screenWidth,
  //               decoration: BoxDecoration(
  //                 image: DecorationImage(
  //                   image: NetworkImage(imageUrl),
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //               child: Image.network(
  //                 imageUrl,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (_, __, ___) => Center(
  //                   child: Icon(Icons.error, color: Colors.red),
  //                 ),
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: images.asMap().entries.map((entry) {
  //           return Container(
  //             width: 8,
  //             height: 8,
  //             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: _currentImageIndex == entry.key
  //                   ? AppColors.primaryColor
  //                   : Colors.grey,
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildImageCarousel(List<String> images, double screenWidth) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() => _currentImageIndex = index);
            },
            autoPlay: true, // Auto slide
            autoPlayInterval: Duration(seconds: 3), // Time between slides
            autoPlayAnimationDuration: Duration(milliseconds: 800), // Animation duration
            autoPlayCurve: Curves.fastOutSlowIn, // Smoother animation curve
            enableInfiniteScroll: true, // Loop the images
            enlargeCenterPage: true, // Slight zoom effect
            scrollPhysics: BouncingScrollPhysics(), // Smooth bounce at edges
          ),
          items: images.map((image) {
            final imageUrl = image.startsWith('http')
                ? image
                : 'http://${NetworkConfig().ipAddress}:5000/uploads/$image';
            print("Loading image: $imageUrl");
            return Builder(
              builder: (context) => Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentImageIndex == entry.key
                    ? AppColors.primaryColor
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => _addToCart(context, widget.itemData),
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: const Text(
          'Add to Cart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}