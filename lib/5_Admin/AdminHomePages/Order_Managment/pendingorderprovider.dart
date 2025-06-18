import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../ip_address.dart';

class PendingOrdersProvider extends ChangeNotifier {
  int _pendingCount = 0;

  int get pendingCount => _pendingCount;

  Future<void> fetchPendingOrdersCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/admin/orders'),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final count = data
            .where((order) =>
        order['status'].toString().toLowerCase() == 'pending')
            .length;

        _pendingCount = count;
        notifyListeners();
      }
    } catch (e) {
      print('Error while fetching pending orders');
      }
  }

  void updatePendingCount(int count) {
    _pendingCount = count;
    notifyListeners();
  }
}
