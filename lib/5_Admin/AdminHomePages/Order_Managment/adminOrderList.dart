import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../ip_address.dart';
import 'adminOrderDetail.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'All';
  List<dynamic> _pendingCancellations = [];

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllOrders();
  }

  // Future<void> _fetchAllOrders() async {
  //   setState(() {
  //     _isLoading = true;
  //     _error = null;
  //   });
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/orders'),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       if (data is List) {
  //         setState(() {
  //           _orders = data.map((item) => Order.fromJson(item)).toList();
  //           _isLoading = false;
  //         });
  //       } else {
  //         setState(() {
  //           _orders = [];
  //           _isLoading = false;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         _error = 'Failed to load orders: ${response.statusCode}';
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _error = 'Error: ${e.toString()}';
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _fetchAllOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/orders'),
      );
      final cancellationsResponse = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/cancellation-requests'),
      );
      if (response.statusCode == 200 && cancellationsResponse.statusCode == 200) {
        final data = json.decode(response.body);
        final cancellationsData = json.decode(cancellationsResponse.body);

        if (data is List) {
          setState(() {
            _orders = data.map((item) => Order.fromJson(item)).toList();
            _pendingCancellations = cancellationsData;
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
          _error = 'Failed to load orders: ${response.statusCode}';
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


  List<Order> get _filteredOrders {
    if (_filterStatus == 'All') {
      return _orders;
    } else {
      return _orders.where((order) =>
      order.status.toLowerCase() == _filterStatus.toLowerCase()
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _filteredOrders.isEmpty
                ? const Center(child: Text('No orders found'))
                : RefreshIndicator(
              onRefresh: _fetchAllOrders,
              child: ListView.builder(
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Status:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _statusOptions.map((status) {
                final isSelected = status == _filterStatus;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: _getStatusColor(status.toLowerCase()),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filterStatus = status;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final hasCancellationRequest = _pendingCancellations.any((cr) =>
    cr['order_id'] == order.orderId && cr['status'] == 'pending');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminOrderDetailsScreen(orderId: order.orderId),
            ),
          ).then((_) => _fetchAllOrders()); // Refresh when returning from details
        },
        child: Stack(
          children: [
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      _buildStatusChip(order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${order.orderDate}'),
                  const SizedBox(height: 4),
                  Text('Customer: ${order.userName}'),
                  const SizedBox(height: 4),
                  Text('Total: PKR ${order.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  Text('Payment: ${order.paymentMethod}'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items: ${order.itemCount}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminOrderDetailsScreen(orderId: order.orderId),
                            ),
                          ).then((_) => _fetchAllOrders());
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasCancellationRequest)
              // Positioned(
              //   top: 8,
              //   right: 8,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: Colors.red.withOpacity(0.9),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: const Text(
              //       'Cancellation Request',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 12,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
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
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _getStatusColor(status.toLowerCase()),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'all':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class Order {
  final int orderId;
  final String orderDate;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String paymentMethod;
  final String userName;
  final int itemCount;
  final String? cancellationStatus;


  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.userName,
    required this.itemCount,
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
      userName: json['user_name'] ?? 'Unknown',
      itemCount: json['item_count'] ?? 0,
      cancellationStatus: json['cancellation_status'],

    );
  }
}