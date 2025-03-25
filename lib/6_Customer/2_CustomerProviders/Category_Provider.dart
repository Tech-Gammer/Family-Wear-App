import 'package:flutter/material.dart';

class Category {
  final String name;
  final String icon;

  Category({required this.name, required this.icon});
}

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [
    Category(name: 'Rings', icon: 'asset/ring.jpg'),
    Category(name: 'Shoes', icon: 'asset/shoes.jpg'),
    Category(name: 'Watches', icon: 'asset/watch.jpg'),
    Category(name: 'Wallets', icon: 'asset/wallet.jpg'),
    Category(name: 'Glasses', icon: 'asset/glasses.jpg'),
    Category(name: 'Dress', icon: 'asset/dress.jpg'),
  ];

  List<Category> get categories => _categories;
}
