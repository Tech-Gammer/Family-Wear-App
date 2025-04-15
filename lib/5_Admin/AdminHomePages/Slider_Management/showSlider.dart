import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Slider_Management/showSlider_Provider.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';

class ShowSliderScreen extends StatefulWidget {
  @override
  _ShowSliderScreenState createState() => _ShowSliderScreenState();
}

class _ShowSliderScreenState extends State<ShowSliderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShowSliderProvider>(context, listen: false).fetchSliderImages();
    });
  }

  void _confirmDelete(BuildContext context, int imageId) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this image?"),
          actions: [
            // Cancel Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.black),
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            /*TextButton(
              onPressed: () {
                Provider.of<ShowSliderProvider>(context, listen: false).deleteImage(imageId);
                Navigator.of(context).pop(); // Close dialog after deletion
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
*/
            // delete Button
            ElevatedButton(
              onPressed: () {
                Provider.of<ShowSliderProvider>(context, listen: false).deleteImage(imageId);
                Navigator.of(context).pop(); // Close dialog after deletion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.lightTextColor,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sliderProvider = Provider.of<ShowSliderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Slider Images")),
      body: sliderProvider.sliderImages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: sliderProvider.sliderImages.length,
        itemBuilder: (context, index) {
          final imageData = sliderProvider.sliderImages[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  child: Image.memory(
                    base64Decode(imageData["image"]),
                    width: 600,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _confirmDelete(context, imageData["id"]),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: AppColors.primaryColor, size: 20),
                    ),
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
