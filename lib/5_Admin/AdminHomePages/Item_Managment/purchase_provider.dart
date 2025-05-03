// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:family_wear_app/ip_address.dart';
//
// class PurchaseProvider with ChangeNotifier {
//   // Form controllers
//   final TextEditingController purchasePriceController = TextEditingController();
//   final TextEditingController quantityController = TextEditingController();
//   final TextEditingController supplierController = TextEditingController();
//   final TextEditingController invoiceController = TextEditingController();
//
//   List<Map<String, dynamic>> _items = [];
//   int? _selectedItemId;
//   DateTime? _selectedDate;
//
//   // Getters
//   List<Map<String, dynamic>> get items => _items;
//   int? get selectedItemId => _selectedItemId;
//   DateTime? get selectedDate => _selectedDate;
//   List<Map<String, dynamic>> _purchases = [];
//
//   List<Map<String, dynamic>> get purchases => _purchases;
//
//   Future<void> fetchPurchases() async {
//     try {
//       final response = await http.get(Uri.parse("http://${NetworkConfig().ipAddress}:5000/purchases"));
//       if (response.statusCode == 200) {
//         _purchases = List<Map<String, dynamic>>.from(json.decode(response.body));
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Error fetching purchases: $e");
//     }
//   }
//
//   Future<bool> deletePurchase(int purchaseId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse("http://${NetworkConfig().ipAddress}:5000/purchase/$purchaseId"),
//       );
//       if (response.statusCode == 200) {
//         await fetchPurchases(); // Refresh list
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print("Delete purchase error: $e");
//       return false;
//     }
//   }
//   // Fetch items for dropdown
//   Future<void> fetchItems() async {
//     final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/items");
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         _items = (json.decode(response.body) as List)
//             .map((item) => {
//           'item_id': item['item_id'],
//           'item_name': item['item_name'],
//           'minimum_qty': item['minimum_qty'],//s
//         })
//             .toList();
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Error fetching items: $e");
//       throw Exception('Failed to load items');
//     }
//   }
//
//   // Set selected item
//   void setSelectedItem(int id) {
//     _selectedItemId = id;
//     notifyListeners();
//   }
//
//   // Set purchase date
//   void setPurchaseDate(DateTime date) {
//     _selectedDate = date;
//     notifyListeners();
//   }
//
//   // Submit purchase
//   Future<bool> submitPurchase(DateTime date, BuildContext context) async {
//
//     if (_selectedItemId == null || _selectedDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an item and date')),
//       );
//       return false;
//     }
//
//     final purchaseData = {
//       'item_id': _selectedItemId,
//       'purchase_date': _selectedDate!.toIso8601String(),
//       'quantity': quantityController.text,
//       'purchase_price': purchasePriceController.text,
//       'supplier_name': supplierController.text,
//       'invoice_no': invoiceController.text,
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse("http://${NetworkConfig().ipAddress}:5000/purchase-item"),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(purchaseData),
//       );
//
//       if (response.statusCode == 201) {
//         clearForm();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print("Purchase error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//       return false;
//     }
//   }
//
//   // Clear form
//   void clearForm() {
//     purchasePriceController.clear();
//     quantityController.clear();
//     supplierController.clear();
//     invoiceController.clear();
//     _selectedItemId = null;
//     _selectedDate = null;
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     purchasePriceController.dispose();
//     quantityController.dispose();
//     supplierController.dispose();
//     invoiceController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:family_wear_app/ip_address.dart';

class PurchaseProvider with ChangeNotifier {
  // Form controllers
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController invoiceController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  int? _selectedItemId;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _purchases = [];

  // Getters
  List<Map<String, dynamic>> get items => _items;
  int? get selectedItemId => _selectedItemId;
  DateTime? get selectedDate => _selectedDate;
  List<Map<String, dynamic>> get purchases => _purchases;

  // Fetch items for dropdown
  Future<void> fetchItems() async {
    final url = Uri.parse("http://${NetworkConfig().ipAddress}:5000/items");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _items = (json.decode(response.body) as List).map((item) => {
          'item_id': item['item_id'],
          'item_name': item['item_name'],
          'minimum_qty': item['minimum_qty'],
        }).toList();

        // Set default selected item
        if (_items.isNotEmpty && _selectedItemId == null) {
          _selectedItemId = _items.first['item_id'];
        }

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  void setSelectedItem(int id) {
    _selectedItemId = id;
    notifyListeners();
  }

  void setPurchaseDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<bool> submitPurchase(DateTime date, BuildContext context) async {
    if (_selectedItemId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item and date')),
      );
      return false;
    }

    final purchaseData = {
      'item_id': _selectedItemId,
      'purchase_date': _selectedDate!.toIso8601String(),
      'quantity': int.tryParse(quantityController.text),
      'purchase_price': double.tryParse(purchasePriceController.text),
      'supplier_name': supplierController.text,
      'invoice_no': invoiceController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("http://${NetworkConfig().ipAddress}:5000/purchase-item"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(purchaseData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        clearForm();
        return true;
      } else {
        print("Failed response: ${response.body}");
      }
      return false;
    } catch (e) {
      print("Purchase error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      return false;
    }
  }

  void clearForm() {
    purchasePriceController.clear();
    quantityController.clear();
    supplierController.clear();
    invoiceController.clear();
    _selectedItemId = null;
    _selectedDate = null;
    notifyListeners();
  }

  @override
  void dispose() {
    purchasePriceController.dispose();
    quantityController.dispose();
    supplierController.dispose();
    invoiceController.dispose();
    super.dispose();
  }

  Future<void> fetchPurchases() async {
    try {
      final response = await http.get(Uri.parse("http://${NetworkConfig().ipAddress}:5000/purchases"));
      if (response.statusCode == 200) {
        _purchases = List<Map<String, dynamic>>.from(json.decode(response.body));
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching purchases: $e");
    }
  }

  Future<bool> deletePurchase(int purchaseId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://${NetworkConfig().ipAddress}:5000/purchase/$purchaseId"),
      );
      if (response.statusCode == 200) {
        await fetchPurchases();
        return true;
      }
      return false;
    } catch (e) {
      print("Delete purchase error: $e");
      return false;
    }
  }
}
