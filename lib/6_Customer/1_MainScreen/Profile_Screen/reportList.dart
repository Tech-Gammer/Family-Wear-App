import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';

class UserBugReportsPage extends StatefulWidget {
  const UserBugReportsPage({super.key});

  @override
  _UserBugReportsPageState createState() => _UserBugReportsPageState();
}

class _UserBugReportsPageState extends State<UserBugReportsPage> {
  late Future<List<dynamic>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _reportsFuture = _fetchReports(userProvider.userId!);
  }

  Future<List<dynamic>> _fetchReports(int userId) async {
    final response = await http.get(
      Uri.parse('http://${NetworkConfig().ipAddress}:5000/user/reports/$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bug Reports')),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reports'));
          }

          final reports = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                child: ListTile(
                  title: Text(report['title']),
                  subtitle: Text(report['description']),
                  trailing: Chip(
                    label: Text(
                      report['status'].replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: _statusColor(report['status']),
                      ),
                    ),
                    backgroundColor: _statusColor(report['status']).withOpacity(0.1),
                  ),
                ),
              );
            },
          );
        },
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
