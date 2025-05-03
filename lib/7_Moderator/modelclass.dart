import 'package:flutter/material.dart';

class Order {
  final String title;
  final String price;
  final String dueTime;
  final String status; // 'Active', 'New', 'Completed', 'Delivered', 'Canceled'
  final String userName;
  final String userAvatar;
  final String orderId;

  Order({
    required this.title,
    required this.price,
    required this.dueTime,
    required this.status,
    required this.userName,
    required this.userAvatar,
    required this.orderId,
  });
}

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [
    Order(
      title: 'Deep edit and enhance your residency ERAS personal statement',
      price: '100',
      dueTime: '33h, 33m',
      status: 'In Progress',
      userName: 'Sufyan12',
      userAvatar: 'asset/sufyan.jpg',
      orderId: '#A1001',
    ),
    Order(
      title: 'Completed ERAS application review',
      price: '75',
      dueTime: 'Completed',
      status: 'Completed',
      userName: 'RahulP',
      userAvatar: 'assets/rahul.jpg',
      orderId: '#A1003',
    ),
    Order(
      title: 'Delivered CV and Personal Statement bundle',
      price: '120',
      dueTime: 'Delivered',
      status: 'Delivered',
      userName: 'UsamaDoc',
      userAvatar: 'assets/usama.jpg',
      orderId: '#A1004',
    ),
    Order(
      title: 'Canceled due to non-response',
      price: '0',
      dueTime: 'N/A',
      status: 'Canceled',
      userName: 'JohnDoe',
      userAvatar: 'asset/watch.jpg',
      orderId: '#A1005',
    ),
  ];

  List<Order> get allOrders => _orders;

  List<Order> get activeOrders => _filterOrders('In Progress');
  List<Order> get completedOrders => _filterOrders('Completed');
  List<Order> get deliveredOrders => _filterOrders('Delivered');
  List<Order> get canceledOrders => _filterOrders('Canceled');

  List<Order> _filterOrders(String status) =>
      _orders.where((order) => order.status == status).toList();

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void removeOrder(int index) {
    _orders.removeAt(index);
    notifyListeners();
  }
}