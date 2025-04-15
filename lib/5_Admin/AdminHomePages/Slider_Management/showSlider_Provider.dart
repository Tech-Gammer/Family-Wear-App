import 'dart:convert';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShowSliderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _sliderImages = [];

  List<Map<String, dynamic>> get sliderImages => _sliderImages;

  Future<void> fetchSliderImages() async {
    final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/get_slider_images");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _sliderImages = data.map((item) => {
          "id": item["id"],
          "image": item["image"]
        }).toList();
        notifyListeners();
      } else {
        throw Exception("Failed to load images");
      }
    } catch (error) {
      print("Error fetching images: $error");
    }
  }

  Future<void> deleteImage(int imageId) async {
    final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/delete_slider_image/$imageId");

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _sliderImages.removeWhere((image) => image["id"] == imageId);
        notifyListeners();
      }
    } catch (error) {
      print("Error deleting image: $error");
    }
  }
}
