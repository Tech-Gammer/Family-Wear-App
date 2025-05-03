import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../ip_address.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, _) {
          if (ordersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ordersProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(ordersProvider.errorMessage));
          }

          if (ordersProvider.orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.orders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildOrderItem(item)),
            const SizedBox(height: 12),
            _buildOrderTotal(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.orderId}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              _formatDate(order.orderDateTime),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Chip(
          label: Text(
            order.status.toUpperCase(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getStatusColor(order.status),
        ),
      ],
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('Qty: ${item.quantity}'),
              ],
            ),
          ),
          Text(
            'PKR ${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          'PKR ${order.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[200]!;
      case 'completed':
        return Colors.green[200]!;
      case 'cancelled':
        return Colors.red[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Orders Provider
class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        // Uri.parse('http://${IP.ip}/orders/$userId'),
        Uri.parse('http://${NetworkConfig().ipAddress}:5000//orders/$userId'),

      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _orders = data.map((json) => Order.fromJson(json)).toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load orders: ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Data Models
class Order {
  final String orderId;
  final String orderDateTime;
  final String status;
  final List<OrderItem> items;
  final double total;

  Order({
    required this.orderId,
    required this.orderDateTime,
    required this.status,
    required this.items,
    required this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      orderDateTime: json['order_datetime'],
      status: json['order_status'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      total: json['total'].toDouble(),
    );
  }
}

class OrderItem {
  final String itemId;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.itemId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['item_id'],
      title: json['item_name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}