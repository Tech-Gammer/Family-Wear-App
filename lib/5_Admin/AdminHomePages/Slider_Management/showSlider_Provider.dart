import 'dart:convert';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ShowSliderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _sliderImages = [];
  bool _isLoading = false;
  bool _hasData = false;
  String _error = '';

  // Public getters
  List<Map<String, dynamic>> get sliderImages => _sliderImages;
  bool get isLoading => _isLoading;
  bool get hasData => _hasData;
  String get error => _error;

  // Unified method to fetch slider images as base64 strings
  Future<void> fetchSliderImagesAsBase64() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("http://${NetworkConfig().ipAddress}:5000/get_slider_images"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _sliderImages = data.map((item) => {
          "id": item["id"],
          "image": item["image"] ?? '' // Use empty string as fallback if null
        }).toList();
        _hasData = true;
      } else {
        _error = "Failed to load images: ${response.statusCode}";
        print(_error);
      }
    } catch (error) {
      _error = "Error fetching base64 images: $error";
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Improved method to fetch slider images and decode to bytes with better error handling
  Future<void> fetchSliderImagesAsBytes() async {
    if (_hasData && _sliderImages.isNotEmpty &&
        _sliderImages.any((image) => image.containsKey('image_bytes') &&
            image['image_bytes'] is Uint8List &&
            (image['image_bytes'] as Uint8List).isNotEmpty)) {
      // Data already exists and has valid image_bytes
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("http://${NetworkConfig().ipAddress}:5000/get_slider_images"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Clear previous data to avoid duplicates
        _sliderImages = [];

        for (var item in data) {
          String base64String = item["image"] ?? '';
          Uint8List bytes;

          try {
            // Safely decode base64 with error handling
            bytes = base64String.isNotEmpty
                ? base64Decode(base64String)
                : Uint8List(0);
          } catch (e) {
            print('Error decoding image: $e');
            bytes = Uint8List(0);
          }

          _sliderImages.add({
            "id": item["id"],
            "image_bytes": bytes,
            "image": base64String // Keep the original base64 string too
          });
        }

        _hasData = _sliderImages.isNotEmpty;
      } else {
        _error = "Failed to load images: ${response.statusCode}";
        print(_error);
      }
    } catch (error) {
      _error = "Error fetching byte images: $error";
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an image from the slider
  Future<void> deleteImage(int imageId) async {
    final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/delete_slider_image/$imageId");

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _sliderImages.removeWhere((image) => image["id"] == imageId);
        notifyListeners();
      } else {
        _error = "Failed to delete image: ${response.statusCode}";
        print(_error);
      }
    } catch (error) {
      _error = "Error deleting image: $error";
      print(_error);
    }
  }

  // Clear current data and reset provider state
  void reset() {
    _sliderImages = [];
    _hasData = false;
    _error = '';
    notifyListeners();
  }

  // Method to pre-cache images for better performance
  void preCacheImages(BuildContext context) {
    for (var item in _sliderImages) {
      if (item.containsKey('image_bytes') &&
          item['image_bytes'] is Uint8List &&
          (item['image_bytes'] as Uint8List).isNotEmpty) {
        // Precache memory images
        precacheImage(MemoryImage(item['image_bytes']), context);
      }
    }
  }

  // Helper method to check if an image has valid bytes
  bool hasValidImageBytes(Map<String, dynamic> image) {
    return image.containsKey('image_bytes') &&
        image['image_bytes'] is Uint8List &&
        (image['image_bytes'] as Uint8List).isNotEmpty;
  }
}