import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../ip_address.dart';

class AdminCancellationRequestsScreen extends StatefulWidget {
  const AdminCancellationRequestsScreen({super.key});

  @override
  State<AdminCancellationRequestsScreen> createState() => _AdminCancellationRequestsScreenState();
}

class _AdminCancellationRequestsScreenState extends State<AdminCancellationRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/cancellation-requests'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _requests = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _processRequest(int requestId, String status) async {
    final notesController = TextEditingController(); // Create the controller here

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Response Notes'),
        content: TextField(
          controller: notesController, // Use the controller
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Optional notes...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final notes = notesController.text; // Get the text from controller
              Navigator.pop(context);

              try {
                final response = await http.put(
                  Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/cancellation-requests/$requestId'),
                  body: json.encode({'status': status, 'admin_notes': notes}),
                  headers: {'Content-Type': 'application/json'},
                );

                if (response.statusCode == 200) {
                  _fetchRequests();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Request $status successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: Text(status.toUpperCase()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancellation Requests')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            child: ListTile(
              title: Text('Order #${request['order_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request['reason']),
                  Text('User: ${request['user_name']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _processRequest(request['request_id'], 'approved'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _processRequest(request['request_id'], 'rejected'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}