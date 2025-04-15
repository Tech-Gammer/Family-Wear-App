import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';
import 'addSlider_Provider.dart';

class UploadImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<AddSliderImageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => imageProvider.uploadSliderImage(context),
        icon: Icon(Icons.save_alt_outlined, color: AppColors.lightTextColor,),
        label: Text("Upload Image", style: TextStyle(color: AppColors.lightTextColor, fontWeight: FontWeight.w700,letterSpacing: 1, fontSize: 16)),
        backgroundColor: AppColors.primaryColor.withOpacity(0.9),
        //child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            GestureDetector(
              onTap: imageProvider.pickImage,
              child: imageProvider.image != null
                  ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    child: Image.file(
                      File(imageProvider.image!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: imageProvider.removeImage,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: AppColors.primaryColor, size: 20),
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 100, color: Colors.grey[600]),
                    SizedBox(height: 5),
                    Text("Tap to Select Image",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            // Image Preview

            /*imageProvider.image != null
                ? Image.file(imageProvider.image!, height: 200, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 100, color: Colors.grey),*/

            /*const SizedBox(height: 20),

            // Pick Image Button
            ElevatedButton.icon(
              onPressed: imageProvider.pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Select Image"),
            ),*/

            /*const SizedBox(height: 10),

            // Upload & Remove Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageProvider.image != null) ...[
                  ElevatedButton(
                    onPressed: () => imageProvider.uploadSliderImage(context),
                    child: const Text("Upload"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: imageProvider.removeImage,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Remove"),
                  ),
                ]
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}
