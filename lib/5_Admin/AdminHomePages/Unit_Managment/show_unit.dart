import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:family_wear_app/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowUnitPage extends StatefulWidget {
  @override
  _ShowUnitPageState createState() => _ShowUnitPageState();
}

class _ShowUnitPageState extends State<ShowUnitPage> {
  List<Map<String, dynamic>> _units = [];
  final TextEditingController _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    final response = await http.get(Uri.parse('http://${NetworkConfig().ipAddress}:5000/get-units'));
    if (response.statusCode == 200) {
      setState(() {
        _units = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      _showSnackbar('Failed to load units.', Colors.red);
    }
  }

  Future<void> _deleteUnit(int unitId) async {
    final response = await http.delete(Uri.parse('http://${NetworkConfig().ipAddress}:5000/delete-unit/$unitId'));
    if (response.statusCode == 200) {
      _showSnackbar('Unit deleted successfully!', Colors.green);
      _fetchUnits();
    } else {
      _showSnackbar('Failed to delete unit.', Colors.red);
    }
  }

  void _showEditDialog(int unitId, String unitName) {
    _unitController.text = unitName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Unit', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _unitController,
            decoration: InputDecoration(hintText: 'Enter unit name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _editUnit(unitId);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editUnit(int unitId) async {
    final response = await http.put(
      Uri.parse('http://${NetworkConfig().ipAddress}:5000/edit-unit/$unitId'),
      body: {'unit_name': _unitController.text},
    );

    if (response.statusCode == 200) {
      _showSnackbar('Unit updated successfully!', Colors.green);
      _unitController.clear();
      _fetchUnits();
    } else {
      _showSnackbar('Failed to update unit.', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Units', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        //backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _units.length,
          itemBuilder: (context, index) {
            final unit = _units[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.category, color: AppColors.primaryColor),
                title: Text(unit['unit_name'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditDialog(unit['unit_id'], unit['unit_name']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: AppColors.primaryColor),
                      onPressed: () => _deleteUnit(unit['unit_id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: _fetchUnits,
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}