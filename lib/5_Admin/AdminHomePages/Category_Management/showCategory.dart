// Flutter Code (Display Screen)

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../ip_address.dart';

class ShowCategories extends StatefulWidget {
  const ShowCategories({Key? key}) : super(key: key);

  @override
  _ShowCategoriesState createState() => _ShowCategoriesState();
}

class _ShowCategoriesState extends State<ShowCategories> {
  List<dynamic> categories = [];

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://${NetworkConfig().ipAddress}:5000/get-categories'));
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      setState(() {
        categories = data['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category List')),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final Uint8List imageBytes = base64Decode(category['category_picture']);
          return ListTile(
            leading: Image.memory(imageBytes, height: 50, width: 50, fit: BoxFit.cover),
            title: Text(category['category_name']),
          );
        },
      ),
    );
  }
}

/*
import 'dart:convert';
import 'dart:typed_data';
import 'package:family_wear_app/5_Admin/AdminHomePages/Category_Management/showCategory_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShowCategories extends StatefulWidget {
  const ShowCategories({Key? key}) : super(key: key);

  @override
  State<ShowCategories> createState() => _ShowCategoriesState();
}

class _ShowCategoriesState extends State<ShowCategories> {
  @override
  void initState() {
    super.initState();
    Provider.of<ShowCategoryProvider>(context, listen: false).fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShowCategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: provider.categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];

          Uint8List? imageBytes;
          if (category["imageBase64"] != null &&
              category["imageBase64"]!.startsWith("data:image")) {
            try {
              // Base64 string extract karna
              String base64String = category["imageBase64"]!.split(',')[1];
              imageBytes = base64Decode(base64String);
            } catch (e) {
              print("Error decoding image: $e");
            }
          }

          return ListTile(
            leading: imageBytes != null
                ? Image.memory(imageBytes, width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.image, size: 50, color: Colors.grey),
            title: Text(category["name"]),
          );
        },
      ),
    );
  }
}
*/
