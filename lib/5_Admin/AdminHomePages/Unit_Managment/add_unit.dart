import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddUnitPage extends StatefulWidget {
  @override
  _AddUnitPageState createState() => _AddUnitPageState();
}

class _AddUnitPageState extends State<AddUnitPage> {
  final TextEditingController _unitController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addUnit() async {
    final unitName = _unitController.text.trim();

    if (unitName.isEmpty) {
      _showSnackBar('Unit name cannot be empty!');
      return;

    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/add_unit'),
        body: {'unit_name': unitName},
      );

      if (response.statusCode == 200) {
        _showSnackBar('Unit added successfully!');
        _unitController.clear();
      } else {
        _showSnackBar('Failed to add unit. Please try again.');
        print('Failed to add unit. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showSnackBar('Error: Unable to connect to server.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Unit'),
        centerTitle: true,
      ),
      floatingActionButton: _isLoading
          ? const CircularProgressIndicator()
          : FloatingActionButton(
        onPressed: _addUnit,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
