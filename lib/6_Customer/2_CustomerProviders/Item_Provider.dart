import 'package:flutter/material.dart';

class Item {
  final String image;
  final String name;
  final String description;
  final String price;
  final String soldItem;
  final double rating;
  bool isFavorite;

  Item({required this.image, required this.name, required this.description, required this.price, required this.soldItem, this.rating = 0.0 , this.isFavorite = false});
}

class ItemProvider with ChangeNotifier {
  final List<Item> _items = [
    Item(image: 'asset/ring.jpg', name: 'Stylish Ring', price: 'PKR5,060', description: 'A beautifully crafted ring perfect for any occasion.', soldItem: '700+', rating: 4.0),
    Item(image: 'asset/shoes.jpg', name: 'Shoes', price: 'PKR120', description: 'Comfortable and stylish shoes for everyday wear.', soldItem: "250+", rating: 5.0),
    Item(image: 'asset/watch.jpg', name: 'Watches', price: 'PKR80', description: 'Elegant wristwatches with a modern design.', soldItem: '300+', rating: 3.7),
    Item(image: 'asset/wallet.jpg', name: 'Men Wallets', price: 'PKR40', description: 'Durable leather wallets with a sleek look.', soldItem: '1000+', rating: 4.2),
    Item(image: 'asset/wallet.jpg', name: 'Men Wallets', price: 'PKR40', description: 'Durable leather wallets with a sleek look.', soldItem: '1000+', rating: 4.2),
    Item(image: 'asset/wallet.jpg', name: 'Men Wallets', price: 'PKR40', description: 'Durable leather wallets with a sleek look.', soldItem: '1000+', rating: 4.2),
  ];

  List<Item> get items => _items;

  void toggleFavorite(int index) {
    _items[index].isFavorite = !_items[index].isFavorite;
    notifyListeners();
  }

}
