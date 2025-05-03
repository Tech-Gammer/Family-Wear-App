// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
// import '../../../ip_address.dart';
// import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
// import 'OrdersDetailPage.dart';
//
// class MyOrdersScreen extends StatefulWidget {
//   const MyOrdersScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MyOrdersScreen> createState() => _MyOrdersScreenState();
// }
//
// class _MyOrdersScreenState extends State<MyOrdersScreen> {
//   List<Order> _orders = [];
//   bool _isLoading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchOrders();
//   }
//
//   Future<void> _fetchOrders() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//
//     try {
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       final userId = userProvider.userId;
//
//       final response = await http.get(
//         Uri.parse('http://${NetworkConfig().ipAddress}:5000/orders/$userId'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data is List) {
//           setState(() {
//             _orders = data.map((item) => Order.fromJson(item)).toList();
//             _isLoading = false;
//           });
//         } else if (data['orders'] != null) {
//           setState(() {
//             _orders = (data['orders'] as List).map((item) => Order.fromJson(item)).toList();
//             _isLoading = false;
//           });
//         } else {
//           setState(() {
//             _orders = [];
//             _isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           _error = 'Failed to load orders';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Error: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Orders'),
//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _fetchOrders,
//         child: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : _error != null
//             ? Center(child: Text(_error!))
//             : _orders.isEmpty
//             ? Center(child: Text('No orders found'))
//             : ListView.builder(
//           itemCount: _orders.length,
//           itemBuilder: (context, index) {
//             final order = _orders[index];
//             return _buildOrderCard(order);
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderCard(Order order) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OrderDetailsScreen(orderId: order.orderId),
//             ),
//           ).then((_) => _fetchOrders()); // Refresh when returning from details
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Order #${order.orderId}',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   _buildStatusChip(order.status),
//                 ],
//               ),
//               SizedBox(height: 8),
//               Text('Date: ${order.orderDate}'),
//               SizedBox(height: 4),
//               Text('Total: PKR ${order.totalAmount.toStringAsFixed(2)}'),
//               SizedBox(height: 4),
//               Text('Payment: ${order.paymentMethod}'),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => OrderDetailsScreen(orderId: order.orderId),
//                         ),
//                       ).then((_) => _fetchOrders());
//                     },
//                     child: Text('View Details'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusChip(String status) {
//     Color statusColor;
//
//     switch (status.toLowerCase()) {
//       case 'pending':
//         statusColor = Colors.orange;
//         break;
//       case 'processing':
//         statusColor = Colors.blue;
//         break;
//       case 'shipped':
//         statusColor = Colors.purple;
//         break;
//       case 'delivered':
//         statusColor = Colors.green;
//         break;
//       case 'cancelled':
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }
//
//     return Chip(
//       label: Text(
//         status.toUpperCase(),
//         style: TextStyle(color: Colors.white, fontSize: 12),
//       ),
//       backgroundColor: statusColor,
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//     );
//   }
// }
//
// class Order {
//   final int orderId;
//   final String orderDate;
//   final double totalAmount;
//   final String status;
//   final String shippingAddress;
//   final String paymentMethod;
//
//   Order({
//     required this.orderId,
//     required this.orderDate,
//     required this.totalAmount,
//     required this.status,
//     required this.shippingAddress,
//     required this.paymentMethod,
//   });
//
//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       orderId: json['order_id'],
//       orderDate: json['order_date'],
//       totalAmount: double.parse(json['total_amount'].toString()),
//       status: json['status'],
//       shippingAddress: json['shipping_address'],
//       paymentMethod: json['payment_method'],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import 'OrdersDetailPage.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/orders/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            _orders = data.map((item) => Order.fromJson(item)).toList();
            _isLoading = false;
          });
        } else if (data['orders'] != null) {
          setState(() {
            _orders = (data['orders'] as List).map((item) => Order.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _orders = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _orders.isEmpty
            ? Center(child: Text('No orders found'))
            : ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            final order = _orders[index];
            return _buildOrderCard(order);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: order.orderId),
            ),
          ).then((_) => _fetchOrders()); // Refresh when returning from details
        },
        child: Column(
          children: [
            // Cancellation request banner
            if (order.hasCancellationRequest)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _getCancellationBannerColor(order.cancellationStatus),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  _getCancellationBannerText(order.cancellationStatus),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.orderId}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      _buildStatusChip(order.status),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Date: ${order.orderDate}'),
                  SizedBox(height: 4),
                  Text('Total: PKR ${order.totalAmount.toStringAsFixed(2)}'),
                  SizedBox(height: 4),
                  Text('Payment: ${order.paymentMethod}'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(orderId: order.orderId),
                            ),
                          ).then((_) => _fetchOrders());
                        },
                        child: Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions for cancellation banner
  Color _getCancellationBannerColor(String? status) {
    if (status == null) return Colors.red.shade700;

    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'approved':
        return Colors.red.shade700;
      case 'rejected':
        return Colors.grey.shade700;
      default:
        return Colors.red.shade700;
    }
  }

  String _getCancellationBannerText(String? status) {
    if (status == null) return 'CANCELLATION REQUESTED';

    switch (status.toLowerCase()) {
      case 'pending':
        return 'CANCELLATION PENDING';
      case 'approved':
        return 'CANCELLATION APPROVED';
      case 'rejected':
        return 'CANCELLATION REJECTED';
      default:
        return 'CANCELLATION REQUESTED';
    }
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        break;
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: statusColor,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

class Order {
  final int orderId;
  final String orderDate;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String paymentMethod;
  final bool hasCancellationRequest;
  final String? cancellationStatus;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    this.hasCancellationRequest = false,
    this.cancellationStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      orderDate: json['order_date'],
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'],
      shippingAddress: json['shipping_address'],
      paymentMethod: json['payment_method'],
      hasCancellationRequest: json['has_cancellation_request'] ?? false,
      cancellationStatus: json['cancellation_status'],
    );
  }
}