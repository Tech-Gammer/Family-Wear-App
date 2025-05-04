import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../../../ip_address.dart';

class AdminBugReportsPage extends StatefulWidget {
  const AdminBugReportsPage({super.key});

  @override
  _AdminBugReportsPageState createState() => _AdminBugReportsPageState();
}

class _AdminBugReportsPageState extends State<AdminBugReportsPage> {
  late Future<List<dynamic>> _reportsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _reportsFuture = _fetchReports();
    });
  }

  Future<List<dynamic>> _fetchReports() async {
    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/reports'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load reports');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _updateReportStatus(int reportId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/reports/$reportId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatusDialog(BuildContext context, dynamic report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Update Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Open'),
                leading: Radio<String>(
                  value: 'open',
                  groupValue: report['status'],
                  onChanged: (String? value) {
                    Navigator.pop(context);
                    _updateReportStatus(report['report_id'], value!);
                  },
                ),
              ),
              ListTile(
                title: const Text('In Progress'),
                leading: Radio<String>(
                  value: 'in_progress',
                  groupValue: report['status'],
                  onChanged: (String? value) {
                    Navigator.pop(context);
                    _updateReportStatus(report['report_id'], value!);
                  },
                ),
              ),
              ListTile(
                title: const Text('Resolved'),
                leading: Radio<String>(
                  value: 'resolved',
                  groupValue: report['status'],
                  onChanged: (String? value) {
                    Navigator.pop(context);
                    _updateReportStatus(report['report_id'], value!);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bug Reports Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<dynamic>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final reports = snapshot.data ?? [];

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      report['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report['description']),
                        const SizedBox(height: 8),
                        Text(
                          'Submitted by: ${report['user_name']} (${report['email']})',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${DateTime.parse(report['created_at']).toLocal()}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () => _showStatusDialog(context, report),
                      child: Chip(
                        label: Text(
                          report['status'].replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(report['status']),
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                        backgroundColor: _statusColor(report['status']).withOpacity(0.1),
                      ),
                    ),
                    onTap: () => _showStatusDialog(context, report),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}