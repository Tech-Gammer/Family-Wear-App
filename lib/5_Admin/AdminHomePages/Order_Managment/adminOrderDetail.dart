/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../ip_address.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderDetails;
  String? _error;
  String _currentStatus = '';
  bool _updatingStatus = false;
  late TextEditingController _adminNotesController;

  final List<String> _statusOptions = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }


  // In _AdminOrderDetailsScreenState class
  Widget _buildCancellationRequest() {
    // Add null check for cancellation request structure
    if (_orderDetails == null ||
        !_orderDetails!.containsKey('cancellation_request') ||
        _orderDetails!['cancellation_request'] == null) {
      return const SizedBox.shrink();
    }

    final request = _orderDetails!['cancellation_request'];
    // Add null checks for individual fields
    final status = request['status'] ?? 'pending';
    final color = _getCancellationStatusColor(status);

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
                Text(
                  'Cancellation Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Icon(Icons.info_outline, color: Colors.red, size: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (status == 'pending')
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: _showAdminCancellationDialog,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (request['request_date'] != null)
              _buildRequestDetail('Request Date:', request['request_date']),
            if (request['response_date'] != null)
              _buildRequestDetail('Response Date:', request['response_date']),
            if (request['reason'] != null)
              _buildRequestDetail('Reason:', request['reason']),
            if (request['admin_notes'] != null)
              _buildRequestDetail('Admin Notes:', request['admin_notes']),
          ],
        ),
      ),
    );
  }

// Add this helper method
  Color _getCancellationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _buildRequestDetail(String label, String value) {
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

// Update cancellation handling methods
  void _showAdminCancellationDialog() {
    _adminNotesController = TextEditingController(
        text: _orderDetails!['cancellation_request']['admin_notes'] ?? ''
    );

    String selectedStatus = _orderDetails!['cancellation_request']['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Process Cancellation Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: ['pending', 'approved', 'rejected']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedStatus = value!),
                  decoration: const InputDecoration(
                    labelText: 'New Status',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _adminNotesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Admin Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _updateCancellationStatus(
                    requestId: _orderDetails!['cancellation_request']['request_id'],
                    newStatus: selectedStatus,
                    adminNotes: _adminNotesController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusColor(selectedStatus),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateCancellationStatus({
    required int requestId,
    required String newStatus,
    required String adminNotes,
  })
  async {
    try {
      final response = await http.put(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/cancellation-requests/$requestId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': newStatus,
          'admin_notes': adminNotes,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request $newStatus successfully')),
        );
        _fetchOrderDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update request: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/order/${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _orderDetails = json.decode(response.body);
          _currentStatus = _orderDetails!['status'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load order details: ${response.statusCode}';
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

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _updatingStatus = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/order/${widget.orderId}/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentStatus = newStatus;
          if (_orderDetails != null) {
            _orderDetails!['status'] = newStatus;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order status updated to $newStatus')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _updatingStatus = false;
      });
    }
  }

  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _statusOptions.length,
              itemBuilder: (context, index) {
                final status = _statusOptions[index];
                return ListTile(
                  title: Text(status),
                  leading: Radio<String>(
                    value: status,
                    groupValue: _currentStatus,
                    onChanged: (String? value) {
                      Navigator.of(context).pop();
                      if (value != null && value != _currentStatus) {
                        _updateOrderStatus(value);
                      }
                    },
                  ),
                  trailing: Icon(
                    _getStatusIcon(status.toLowerCase()),
                    color: _getStatusColor(status.toLowerCase()),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (status != _currentStatus) {
                      _updateOrderStatus(status);
                    }
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.engineering;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
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

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(status.toLowerCase()).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(status.toLowerCase()),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status.toLowerCase()),
            color: _getStatusColor(status.toLowerCase()),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(status.toLowerCase()),
              fontWeight: FontWeight.bold,
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

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', _orderDetails!['user_name'] ?? 'Not available'),
            _buildInfoRow('Email', _orderDetails!['user_email'] ?? 'Not available'),
            _buildInfoRow('Phone', _orderDetails!['user_phone'] ?? 'Not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
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
                if (_updatingStatus)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  GestureDetector(
                    onTap: _showStatusChangeDialog,
                    child: Row(
                      children: [
                        _buildStatusBadge(_orderDetails!['status']),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 16),
                      ],
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items Subtotal:'),
                Text('PKR ${(_orderDetails!['total_amount'] as num).toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'PKR ${(_orderDetails!['total_amount'] as num).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrderDetails,
          ),
        ],
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
            const SizedBox(height: 16),
            _buildCustomerInfo(),
            const SizedBox(height: 16),
            _buildCancellationRequest(),
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
            _buildOrderSummary(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading || _error != null || _orderDetails == null
          ? null
          : BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton(
            onPressed: _showStatusChangeDialog,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 1),
            ),
            child: const Text('Change Order Status'),
          ),
        ),
      ),
    );
  }
}*/


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../ip_address.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderDetails;
  String? _error;
  String _currentStatus = '';
  bool _updatingStatus = false;
  late TextEditingController _adminNotesController;

  final List<String> _statusOptions = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  @override
  void dispose() {
    _adminNotesController.dispose();
    super.dispose();
  }

  Widget _buildCancellationRequest() {
    if (_orderDetails == null ||
        !_orderDetails!.containsKey('cancellation_request') ||
        _orderDetails!['cancellation_request'] == null) {
      return const SizedBox.shrink();
    }

    final request = _orderDetails!['cancellation_request'];
    final status = request['status'] ?? 'pending';
    final color = _getCancellationStatusColor(status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade50,
              Colors.red.shade100.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel, color: color, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Cancellation Request',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (status == 'pending')
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _showAdminCancellationDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Process Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              const Divider(height: 24, color: Colors.redAccent),
              if (request['request_date'] != null)
                _buildRequestDetail('Request Date:', request['request_date']),
              if (request['response_date'] != null)
                _buildRequestDetail('Response Date:', request['response_date']),
              if (request['reason'] != null)
                _buildRequestDetail('Reason:', request['reason']),
              if (request['admin_notes'] != null)
                _buildRequestDetail('Admin Notes:', request['admin_notes']),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCancellationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green.shade700;
      case 'rejected': return Colors.red.shade700;
      case 'pending': return Colors.orange.shade700;
      default: return Colors.grey.shade700;
    }
  }

  Widget _buildRequestDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
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

  void _showAdminCancellationDialog() {
    _adminNotesController = TextEditingController(
        text: _orderDetails!['cancellation_request']['admin_notes'] ?? ''
    );

    String selectedStatus = _orderDetails!['cancellation_request']['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Process Cancellation',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['pending', 'approved', 'rejected']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedStatus = value!),
                    decoration: InputDecoration(
                      labelText: 'New Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _adminNotesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Admin Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          await _updateCancellationStatus(
                            requestId: _orderDetails!['cancellation_request']['request_id'],
                            newStatus: selectedStatus,
                            adminNotes: _adminNotesController.text,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getStatusColor(selectedStatus),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateCancellationStatus({
    required int requestId,
    required String newStatus,
    required String adminNotes,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/cancellation-requests/$requestId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': newStatus,
          'admin_notes': adminNotes,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $newStatus successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _fetchOrderDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update request: ${response.body}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/order/${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _orderDetails = json.decode(response.body);
          _currentStatus = _orderDetails!['status'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load order details: ${response.statusCode}';
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

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      _updatingStatus = true;
    });

    try {
      final response = await http.put(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/order/${widget.orderId}/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentStatus = newStatus;
          if (_orderDetails != null) {
            _orderDetails!['status'] = newStatus;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order status updated to $newStatus'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${response.statusCode}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    } finally {
      setState(() {
        _updatingStatus = false;
      });
    }
  }

  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Order Status',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _statusOptions.length,
                    itemBuilder: (context, index) {
                      final status = _statusOptions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 0,
                        color: _currentStatus == status
                            ? _getStatusColor(status.toLowerCase()).withOpacity(0.1)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            color: _getStatusColor(status.toLowerCase())
                                .withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            status,
                            style: TextStyle(
                              fontWeight: _currentStatus == status
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          leading: Radio<String>(
                            value: status,
                            groupValue: _currentStatus,
                            onChanged: (String? value) {
                              Navigator.of(context).pop();
                              if (value != null && value != _currentStatus) {
                                _updateOrderStatus(value);
                              }
                            },
                            activeColor: _getStatusColor(status.toLowerCase()),
                          ),
                          trailing: Icon(
                            _getStatusIcon(status.toLowerCase()),
                            color: _getStatusColor(status.toLowerCase()),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            if (status != _currentStatus) {
                              _updateOrderStatus(status);
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.hourglass_empty;
      case 'processing': return Icons.engineering;
      case 'shipped': return Icons.local_shipping;
      case 'delivered': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(status.toLowerCase()).withOpacity(0.2),
            _getStatusColor(status.toLowerCase()).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getStatusColor(status.toLowerCase()),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status.toLowerCase()),
            color: _getStatusColor(status.toLowerCase()),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(status.toLowerCase()),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
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
                    color: Colors.grey[100],
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey[400]),
                  );
                },
              )
                  : Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: Icon(Icons.image, color: Colors.grey[400]),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'PKR ${(item['price'] as num).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 1,
                        height: 14,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Quantity : ${item['quantity']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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

  Widget _buildCustomerInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', _orderDetails!['user_name'] ?? 'Not available'),
            _buildInfoRow('Email', _orderDetails!['user_email'] ?? 'Not available'),
            _buildInfoRow('Phone', _orderDetails!['user_phone'] ?? 'Not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
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

  Widget _buildOrderHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order No: ${widget.orderId}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_updatingStatus)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                else
                  GestureDetector(
                    onTap: _showStatusChangeDialog,
                    child: Row(
                      children: [
                        _buildStatusBadge(_orderDetails!['status']),
                        const SizedBox(width: 8),
                        Icon(Icons.edit,
                            size: 18,
                            color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOrderDetailRow(Icons.calendar_today,
                'Date:', _orderDetails!['order_date']),
            const SizedBox(height: 12),
            _buildOrderDetailRow(Icons.payment,
                'Payment Method:', _orderDetails!['payment_method']),
            const SizedBox(height: 12),
            _buildOrderDetailRow(Icons.location_on,
                'Shipping Address:', _orderDetails!['shipping_address']),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width:8),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Items Subtotal:',
                'PKR ${(_orderDetails!['total_amount'] as num).toStringAsFixed(2)}'),
            const Divider(height: 24, thickness: 1),
            _buildSummaryRow(
              'Order Total:',
              'PKR ${(_orderDetails!['total_amount'] as num).toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.grey.shade800 : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green.shade700 : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order No: ${widget.orderId}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrderDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading order details...'),
          ],
        ),
      )
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48,
                color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrderDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _orderDetails == null
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 48,
                color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No order details found',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 20),
            _buildCustomerInfo(),
            const SizedBox(height: 20),
            _buildCancellationRequest(),
            const SizedBox(height: 24),
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_orderDetails!['items'] as List)
                .map((item) => _buildItemCard(item))
                .toList(),
            const SizedBox(height: 20),
            _buildOrderSummary(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading || _error != null || _orderDetails == null
          ? null
          : BottomAppBar(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ElevatedButton(
          onPressed: _showStatusChangeDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 2,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text(
                'Change Order Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}