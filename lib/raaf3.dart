/*
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
*/


// import 'dart:convert';
// import 'package:family_wear_app/ip_address.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class ShowSliderProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _sliderImages = [];
//   List<Map<String, dynamic>> get sliderImages => _sliderImages;
//   bool _isLoading = false;
//   bool _hasData = false;
//   bool get hasData => _hasData; // Public getter
//
//
//   Future<void> fetchSliderImages() async {
//
//     if (_hasData) return; // Prevent refetch if data exists
//
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/get_slider_images");
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);
//         _sliderImages = data.map((item) => {
//           "id": item["id"],
//           "image": item["image"]
//         }).toList();
//
//         _hasData = true;
//         notifyListeners();
//       } else {
//         throw Exception("Failed to load images");
//       }
//     } catch (error) {
//       print("Error fetching images: $error");
//     }finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> deleteImage(int imageId) async {
//     final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/delete_slider_image/$imageId");
//
//     try {
//       final response = await http.delete(url);
//       if (response.statusCode == 200) {
//         _sliderImages.removeWhere((image) => image["id"] == imageId);
//         notifyListeners();
//       }
//     } catch (error) {
//       print("Error deleting image: $error");
//     }
//   }
// }

