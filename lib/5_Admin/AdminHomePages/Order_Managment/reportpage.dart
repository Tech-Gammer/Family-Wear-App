import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../ip_address.dart';
import 'order_report_details_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  bool _isLoading = true;
  String? _error;

  int totalOrders = 0;
  int pendingOrders = 0;
  int cancelledOrders = 0;
  int deliveredOrders = 0;
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/orders'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          totalOrders = data.length;
          pendingOrders = data
              .where((order) =>
          order['status'].toString().toLowerCase() == 'pending')
              .length;
          cancelledOrders = data
              .where((order) =>
          order['status'].toString().toLowerCase() == 'cancelled')
              .length;
          deliveredOrders = data
              .where((order) =>
          order['status'].toString().toLowerCase() == 'delivered')
              .length;
          totalRevenue = data.fold<double>(0.0, (sum, order) {
            return sum +
                double.tryParse(order['total_amount'].toString())!;
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to fetch data";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchReportData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          childAspectRatio: .9,
          mainAxisSpacing: 16,
          children: [
            _buildReportCard("Total Orders", totalOrders.toString(), Colors.blue, 'all'),
            _buildReportCard("Pending", pendingOrders.toString(), Colors.orange, 'pending'),
            _buildReportCard("Cancelled", cancelledOrders.toString(), Colors.red, 'cancelled'),
            _buildReportCard("Delivered", deliveredOrders.toString(), Colors.green, 'delivered'),
            _buildReportCard("Total Revenue", "PKR ${totalRevenue.toStringAsFixed(2)}", Colors.purple, 'all'),

          ],
        ),
      ),
    );
  }


  Widget _buildReportCard(String title, String value, Color color, String statusFilter) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderReportDetailsScreen(
              title: title,
              statusFilter: statusFilter,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
