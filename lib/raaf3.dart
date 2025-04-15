/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';

class raaf3 extends StatelessWidget {
  const raaf3({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShowItemProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final item = provider.items[index];
            List<String> images = item['item_image'];  // Multiple images list

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
                              */
/*image: DecorationImage(
                                image: AssetImage(item.image),
                                fit: BoxFit.cover,
                              ),*//*

                            ),
                            child:  PageView.builder(
                              itemCount: images.length,
                              itemBuilder: (context, imgIndex) {
                                return Image.network(images[imgIndex], fit: BoxFit.cover);
                              },
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
                        padding: const EdgeInsets.all(8.0),
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
                                    item['item_name'],
                                    overflow: TextOverflow.ellipsis, // Handle text overflow
                                    maxLines: 1, // Limit to a single line
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenHeight * 0.018,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                // Price
                                Text(
                                  item['sale_price'],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: screenHeight * 0.016,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.001),
                            // Item Description
                            Text(
                              item['item_description'],
                              overflow: TextOverflow.ellipsis, // Handle text overflow
                              maxLines: 1, // Limit description to 2 lines
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: screenHeight * 0.015,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.005),
                            // Row for Item Sold and Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Sold Items
                                Text(
                                  item['minimum_qty'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    //color: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkTextColor,
                                    fontSize: screenHeight * 0.015,
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
                                        size: screenHeight * 0.02,
                                      );
                                    } else if (index < item.rating) {
                                      // Half star
                                      return Icon(
                                        Icons.star_half,
                                        color: Colors.orange,
                                        size: screenHeight * 0.02,
                                      );
                                    } else {
                                      // Empty star
                                      return Icon(
                                        Icons.star_border,
                                        color: Colors.orange,
                                        size: screenHeight * 0.02,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
*/


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ip_address.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      final response = await http.post(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/get-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load profile.")));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
          ? Center(child: Text("No user data found"))
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userData!['user_image'] != null)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: MemoryImage(base64Decode(userData!['user_image'])),
                ),
              ),
            SizedBox(height: 16),
            Text("Name: ${userData!['user_name'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            Text("Email: ${userData!['email'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            Text("Phone: ${userData!['phone_no'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
            Text("Gender: ${userData!['gender'] ?? 'N/A'}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
