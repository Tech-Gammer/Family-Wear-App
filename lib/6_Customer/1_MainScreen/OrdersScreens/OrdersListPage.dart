
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
  String _filterStatus = 'All';

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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(isLargeScreen),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchOrders,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : _filteredOrders.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _fetchOrders,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return _buildOrderCard(order, isLargeScreen);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 24 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Status:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isLargeScreen ? 18 : 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: isLargeScreen ? 50 : 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _statusOptions.map((status) {
                final isSelected = status == _filterStatus;
                return Padding(
                  padding: EdgeInsets.only(right: isLargeScreen ? 12 : 8),
                  child: ChoiceChip(
                    label: Text(
                      status,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16 : 14,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: _getStatusColor(status.toLowerCase()),
                    backgroundColor: Colors.grey[200],
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

  Widget _buildOrderCard(Order order, bool isLargeScreen) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getStatusColor(order.status.toLowerCase()),
              width: 6,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(orderId: order.orderId),
              ),
            ).then((_) => _fetchOrders());
          },
          child: Stack(
            children: [
              if (order.hasCancellationRequest)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCancellationBannerColor(order.cancellationStatus),
                          _getCancellationBannerColor(order.cancellationStatus).withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          _getCancellationBannerText(order.cancellationStatus),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  order.hasCancellationRequest ? 30 : 16,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order No : ${order.orderId}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 18 : 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text( "Date : ${order.orderDate}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: isLargeScreen ? 16 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(order.status, isLargeScreen),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Order Details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.payment, 'Payment', order.paymentMethod, isLargeScreen),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.location_on, 'Address', order.shippingAddress, isLargeScreen),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isLargeScreen ? 16 : 14,
                              ),
                            ),
                            Text(
                              'PKR ${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isLargeScreen ? 18 : 16,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(orderId: order.orderId),
                              ),
                            ).then((_) => _fetchOrders());
                          },
                          icon: const Icon(Icons.remove_red_eye, size: 18),
                          label: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 16 : 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 2,
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 20 : 12,
                              vertical: isLargeScreen ? 12 : 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isLargeScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isLargeScreen ? 20 : 18,
          color: Colors.grey[600],
        ),
        SizedBox(width: isLargeScreen ? 12 : 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isLargeScreen ? 16 : 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, bool isLargeScreen) {
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: isLargeScreen ? 14 : 12,
        ),
      ),
      backgroundColor: _getStatusColor(status.toLowerCase()),
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 12 : 8,
        vertical: 0,
      ),
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