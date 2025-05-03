
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderDetails;
  String? _error;
  bool _processingCancellation = false;
  bool _cancellationRequested = false;
  final TextEditingController _cancellationReasonController = TextEditingController();

  @override
  void dispose() {
    _cancellationReasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  void _showCancellationRequestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Request Order Cancellation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for cancellation:'),
              const SizedBox(height: 10),
              TextField(
                controller: _cancellationReasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter reason...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _processingCancellation ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _processingCancellation ? null : _submitCancellationRequest,
              child: _processingCancellation
                  ? const CircularProgressIndicator()
                  : const Text('Submit Request'),
            ),
          ],
        );
      },
    );
  }

  void _submitCancellationRequest() async {
    if (_cancellationReasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a cancellation reason')),
      );
      return;
    }

    setState(() => _processingCancellation = true);

    try {
      final response = await http.post(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/order/${widget.orderId}/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': Provider.of<UserProvider>(context, listen: false).userId,
          'reason': _cancellationReasonController.text,
        }),
      );

      if (response.statusCode == 200) {
        _fetchOrderDetails(); // Refresh order details
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cancellation request submitted')),
        );
      } else {
        throw Exception('Failed to submit request');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _processingCancellation = false);
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/order/${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _orderDetails = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load order details';
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
      default:
        return Colors.grey;
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

  Widget _buildCancellationRequestSection() {
    final cancellationRequest = _orderDetails?['cancellation_request'];

    if (cancellationRequest == null) {
      bool canRequestCancellation = _orderDetails != null &&
          ['pending', 'processing'].contains(_orderDetails!['status'].toString().toLowerCase());

      return canRequestCancellation
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.cancel),
          label: const Text('Request Cancellation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: _processingCancellation ? null : _showCancellationRequestDialog,
        ),
      )
          : const SizedBox.shrink();
    }

    final requestStatus = cancellationRequest['status'] ?? 'pending';
    final requestDate = cancellationRequest['request_date'] ?? 'Unknown date';
    final reason = cancellationRequest['reason'] ?? 'No reason provided';
    final adminNotes = cancellationRequest['admin_notes'];
    final responseDate = cancellationRequest['response_date'];

    Color statusColor = requestStatus.toLowerCase() == 'approved'
        ? Colors.green
        : requestStatus.toLowerCase() == 'rejected'
        ? Colors.red
        : Colors.orange;
    print(adminNotes);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Cancellation Request',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.info_outline, color: Colors.red),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    requestStatus.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 12),
            // Text('Submitted on: $requestDate'),
            // const SizedBox(height: 8),
            // const Text(
            //   'Reason:',
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 4),
            // Text(reason),
            const SizedBox(height: 12),
            _buildCustomerRequestDetail('Submitted on:', requestDate),
            if (responseDate != null)
              _buildCustomerRequestDetail('Response Date:', responseDate),
            const SizedBox(height: 8),
            _buildCustomerRequestDetail('Reason:', reason),
            if (adminNotes != null)
              _buildCustomerRequestDetail('Admin Response:', adminNotes),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRequestDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item['image_url'] != null
                  ? Image.network(
                item['image_url'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              )
                  : Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item_name'] ?? 'Unnamed Item',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'PKR ${(item['price'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Qty: ${item['quantity']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: PKR ${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Order Total:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'PKR ${(_orderDetails!['total_amount'] as num).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(_orderDetails!['status']),
              ],
            ),
            const SizedBox(height: 12),
            Text('Date: ${_orderDetails!['order_date']}'),
            const SizedBox(height: 8),
            Text('Payment Method: ${_orderDetails!['payment_method']}'),
            const SizedBox(height: 16),
            const Text(
              'Shipping Address:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_orderDetails!['shipping_address']),
            const SizedBox(height: 16),

            // Cancellation request section
            _buildCancellationRequestSection(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId}'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _orderDetails == null
          ? const Center(child: Text('No order details found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 24),
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...(_orderDetails!['items'] as List)
                .map((item) => _buildItemCard(item))
                .toList(),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            _buildOrderSummary(),
          ],
        ),
      ),
    );
  }
}