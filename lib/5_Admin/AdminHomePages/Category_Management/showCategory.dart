/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import '../../../ip_address.dart';

class ShowCategories extends StatefulWidget {
  @override
  _ShowCategoriesState createState() => _ShowCategoriesState();
}

class _ShowCategoriesState extends State<ShowCategories> {
  List categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://${NetworkConfig().ipAddress}:5000/categories'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        categories = data;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('http://${NetworkConfig().ipAddress}:5000/delete-category/$id'));

    if (response.statusCode == 200) {
      setState(() {
        categories.removeWhere((category) => category['category_id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Category deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete category")),
      );
    }
  }

  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Base64 Decode Error: $e");
      return null;
    }
  }

  // Show confirmation dialog before deleting
  void _showDeleteConfirmation(int categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this category?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteCategory(categoryId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Yes", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1, // Aspect ratio for each grid item
        ),
        padding: EdgeInsets.all(10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String? imageString = categories[index]['category_picture'] as String?;
          Uint8List? imageBytes = _decodeImage(imageString);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 5,

            child: Stack(
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageBytes != null
                          ? Image.memory(
                        imageBytes,
                        width: double.infinity,
                        height: 110,
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        categories[index]['category_name'] ?? 'No Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(categories[index]['category_id']);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
*/


import 'dart:convert';
import 'dart:ui';
import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../ip_address.dart';

class ShowCategories extends StatefulWidget {
  @override
  _ShowCategoriesState createState() => _ShowCategoriesState();
}

class _ShowCategoriesState extends State<ShowCategories> {
  List categories = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/categories'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/delete-category/$id'),
      );

      if (response.statusCode == 200) {
        setState(() {
          categories.removeWhere((category) => category['category_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Category deleted successfully"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      } else {
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete category"),
          backgroundColor: AppColors.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
  }

  Uint8List? _decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Base64 Decode Error: $e");
      return null;
    }
  }

  void _showDeleteConfirmation(int categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion", style: TextStyle(fontWeight: FontWeight.bold)),
          content: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                TextSpan(text: "Are you sure you want to delete "),
                TextSpan(
                    text: "'$categoryName'?",
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          actions: <Widget>[
            /*ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Added border radius
                ),
                //backgroundColor: Colors.grey[200], // Optional: Add a light background
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                deleteCategory(categoryId);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Added border radius
                ),
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                foregroundColor: AppColors.primaryColor, // Text color
              ),
              child: Text(
                "Delete",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),*/
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.black),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
              ),
              child: const Text(
                'Cancel',
                //style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                deleteCategory(categoryId);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.lightTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            /*TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
            ),*/
            /*TextButton(
              onPressed: () {
                deleteCategory(categoryId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),*/
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Responsive values
    final gridCount = screenWidth > 600 ? (isPortrait ? 3 : 4) : 2;
    final cardAspectRatio = screenWidth > 600 ? (isPortrait ? 0.85 : 1.1) : 0.9;
    final titleFontSize = screenWidth > 600 ? 18.0 : 16.0;
    final appBarElevation = screenWidth > 600 ? 4.0 : 0.0;
    final paddingValue = screenWidth > 600 ? 16.0 : 4.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: screenWidth > 600 ? 22 : 20,
          ),
        ),
        //backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: appBarElevation,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: screenWidth > 600 ? 28 : 24),
            onPressed: fetchCategories,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Loading Categories...",
              style: TextStyle(
                color: AppColors.primaryColor.withOpacity(0.6),
                fontSize: screenWidth > 600 ? 18 : 16,
              ),
            ),
          ],
        ),
      )
          : _hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth > 600 ? 56 : 48,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Failed to load categories",
              style: TextStyle(
                fontSize: screenWidth > 600 ? 20 : 18,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              onPressed: fetchCategories,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth > 600 ? 32 : 24,
                  vertical: screenWidth > 600 ? 16 : 12,
                ),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 18 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )
          : categories.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: screenWidth > 600 ? 56 : 48,
              color: Colors.grey,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "No categories found",
              style: TextStyle(
                fontSize: screenWidth > 600 ? 20 : 18,
                color: Colors.grey,
              ),
            ),
            if (screenWidth > 600) SizedBox(height: screenHeight * 0.01),
            if (screenWidth > 600) Text(
              "Add a new category to get started",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: EdgeInsets.all(paddingValue),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            crossAxisSpacing: paddingValue,
            mainAxisSpacing: paddingValue,
            childAspectRatio: cardAspectRatio,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            String? imageString =
            categories[index]['category_picture'] as String?;
            Uint8List? imageBytes = _decodeImage(imageString);

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              shadowColor: Colors.deepPurple.withOpacity(0.2),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  // Add your onTap functionality here
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full card background image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: imageBytes != null
                          ? Image.memory(imageBytes, fit: BoxFit.cover,)
                          : Container(
                        color: AppColors.lightBackgroundColor,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: screenWidth > 600 ? 48 : 40,
                            color: AppColors.lightBackgroundColor,
                          ),
                        ),
                      ),
                    ),

                    // Dark overlay for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                          stops: [0.0, 0.1, 0.8, 1.0],
                        ),
                      ),
                    ),

                    // Category name at the top
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              categories[index]['category_name'] ?? 'Unnamed Category',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: titleFontSize,
                                color: AppColors.lightTextColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Delete button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withOpacity(0.9),
                        shape: CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _showDeleteConfirmation(
                              categories[index]['category_id'],
                              categories[index]['category_name'] ??
                                  'this category',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.delete_outline,
                              size: screenWidth > 600 ? 24 : 20,
                              color: AppColors.primaryColor,
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
        ),
      ),
    );
  }
}