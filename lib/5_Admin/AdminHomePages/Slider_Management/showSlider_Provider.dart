import 'dart:convert';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ShowSliderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _sliderImages = [];
  bool _isLoading = false;
  bool _hasData = false;
  bool get hasData => _hasData; // Public getter

  List<Map<String, dynamic>> get sliderImages => _sliderImages;
  bool get isLoading => _isLoading;
  // Future<void> fetchSliderImages() async {
  //   final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/get_slider_images");
  //
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);
  //       _sliderImages = data.map((item) => {
  //         "id": item["id"],
  //         "image": item["image"]
  //       }).toList();
  //       notifyListeners();
  //     } else {
  //       throw Exception("Failed to load images");
  //     }
  //   } catch (error) {
  //     print("Error fetching images: $error");
  //   }
  // }
  Future<void> fetchSliderImages() async {
    if (_hasData) return; // Prevent refetch if data exists

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse("http://${NetworkConfig().ipAddress}:5000/get_slider_images"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _sliderImages = data.map((item) {
          Uint8List bytes = base64Decode(item["image"]);
          return {"id": item["id"], "image_bytes": bytes};
        }).toList();
        _hasData = true;
      }
    } catch (error) {
      print("Error fetching images: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
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
