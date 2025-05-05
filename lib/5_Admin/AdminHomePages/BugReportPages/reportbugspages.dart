/*
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
}*/


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
        String? selectedStatus = report['status'];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Update Status", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['open', 'in_progress', 'resolved'].map((status) {
              return RadioListTile<String>(
                title: Text(status.replaceAll('_', ' ').toUpperCase()),
                value: status,
                groupValue: selectedStatus,
                onChanged: (String? value) {
                  Navigator.pop(context);
                  _updateReportStatus(report['report_id'], value!);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bug Reports', style: TextStyle(fontWeight: FontWeight.bold), ),
        centerTitle: true,
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

            if (reports.isEmpty) {
              return const Center(child: Text("No bug reports found."));
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showStatusDialog(context, report),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submitted by : ${report['user_name']}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'Email : ${report['email']}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            report['title'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(report['description']),
                          const SizedBox(height: 12),
                          /*Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                             */
                          /* Expanded(
                                child: Text(
                                  '${report['user_name']} (${report['email']})',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.033,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),*//*
                            ],
                          ),*/
                          Divider(height: 2,),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 16, weight: 2.0,),
                                      Text(
                                        ' Created: ',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          //color: Colors.grey[600],
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '      ${DateTime.parse(report['created_at']).toLocal()}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Chip(
                                  label: Text(
                                    report['status'].replaceAll('_', ' ').toUpperCase(),
                                    style: TextStyle(
                                      color: _statusColor(report['status']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  backgroundColor: _statusColor(report['status']).withOpacity(0.15),
                                  shape: StadiumBorder(),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                         /* Align(
                            alignment: Alignment.centerRight,
                            child: Chip(
                              label: Text(
                                report['status'].replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(report['status']),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _statusColor(report['status']).withOpacity(0.15),
                              shape: StadiumBorder(),
                            ),
                          )*/
                        ],
                      ),
                    ),
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
