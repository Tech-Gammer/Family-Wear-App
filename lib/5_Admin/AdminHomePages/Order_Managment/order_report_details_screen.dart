import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../ip_address.dart';

class OrderReportDetailsScreen extends StatefulWidget {
  final String title;
  final String statusFilter;

  const OrderReportDetailsScreen({
    super.key,
    required this.title,
    required this.statusFilter,
  });

  @override
  State<OrderReportDetailsScreen> createState() => _OrderReportDetailsScreenState();
}

class _OrderReportDetailsScreenState extends State<OrderReportDetailsScreen> {
  List<dynamic> filteredOrders = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/orders'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          filteredOrders = widget.statusFilter == 'all'
              ? data
              : data.where((order) =>
          order['status'].toString().toLowerCase() ==
              widget.statusFilter.toLowerCase()).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch orders';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> generateAndPrintPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Text('${widget.title} Orders Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          ...filteredOrders.map((order) {
            return pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Order ID: ${order['order_id']}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('User: ${order['user_name'] ?? 'N/A'}'),
                  pw.Text('Date: ${order['order_date']}'),
                  pw.Text('Amount: PKR ${order['total_amount']}'),
                  pw.Text('Status: ${order['status'].toUpperCase()}'),
                  pw.Divider(),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: generateAndPrintPdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : filteredOrders.isEmpty
          ? const Center(child: Text('No orders found'))
          : ListView.builder(
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('Order #${order['order_id']} - PKR ${order['total_amount']}'),
              subtitle: Text('User: ${order['user_name'] ?? 'N/A'}\nDate: ${order['order_date']}'),
              trailing: Chip(
                label: Text(order['status'].toUpperCase()),
                backgroundColor: Colors.blueAccent,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
