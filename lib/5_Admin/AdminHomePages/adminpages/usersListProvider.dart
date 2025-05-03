import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../ip_address.dart';


class AllUserProvider with ChangeNotifier {
  List _users = [];
  List _filteredUsers = [];
  String _searchQuery = '';
  String _selectedRole = 'All';
  bool _isLoading = true;

  List<Map<String, dynamic>> _userImages = [];

  List<Map<String, dynamic>> get userImages => _userImages;
  List get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;
  String get selectedRole => _selectedRole;

  AllUserProvider() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse("http://${NetworkConfig().ipAddress}:5000/admins-and-moderators"),
      );

      if (response.statusCode == 200) {
        _users = json.decode(response.body);
        //List<dynamic> data = json.decode(response.body);
        _filteredUsers = List.from(_users);
      }
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSelectedRole(String role) {
    _selectedRole = role;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedRole = 'All';
    _filteredUsers = List.from(_users);
    notifyListeners();
  }

  Future<void> updateUserRole(String userId, int newRole) async {
    try {
      final response = await http.put(
        Uri.parse("http://${NetworkConfig().ipAddress}:5000/update-user-role"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'newRole': newRole}),
      );

      if (response.statusCode == 200) {
        // Refresh the user list after successful update
        await fetchUsers();
      } else {
        throw Exception('Failed to update role');
      }
    } catch (e) {
      print("Error updating role: $e");
      rethrow;
    }
  }


  void _applyFilters() {
    int? roleNum;
    if (_selectedRole == 'Admin') {
      roleNum = 0;
    } else if (_selectedRole == 'Users') {
      roleNum = 1;
    } else if (_selectedRole == 'Moderator') {
      roleNum = 2;
    } else {
      roleNum = null; // Handle 'All' or other cases
    }

    _filteredUsers = _users.where((user) {
      final name = user['user_name'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      final id = user['user_id'].toString();

      final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase()) ||
          id.contains(_searchQuery);

      final matchesRole = roleNum == null || user['role'] == roleNum;

      return matchesSearch && matchesRole;
    }).toList();

    notifyListeners();
  }
}