import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';
import 'purchase_provider.dart';

class PurchaseListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
        centerTitle: true,
        elevation: 2,
        // backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder(
        future: Provider.of<PurchaseProvider>(context, listen: false).fetchPurchases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Consumer<PurchaseProvider>(
            builder: (context, provider, _) {
              if (provider.purchases.isEmpty) {
                return const Center(
                  child: Text(
                    'No purchases found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.purchases.length,
                itemBuilder: (context, index) {
                  final purchase = provider.purchases[index];
                  return PurchaseListItem(
                    purchase: purchase,
                    onDelete: () => _deletePurchase(context, provider, purchase),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _deletePurchase(BuildContext context, PurchaseProvider provider, Map<String, dynamic> purchase) async {
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('This will deduct ${purchase['quantity']} from item stock. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deletePurchase(purchase['purchase_id']);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase deleted successfully')),
        );
      }
    }
  }
}

class PurchaseListItem extends StatelessWidget {
  final Map<String, dynamic> purchase;
  final VoidCallback onDelete;

  const PurchaseListItem({required this.purchase, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\PKr ', decimalDigits: 2);
    final dateFormatted = DateFormat('MMM d, yyyy').format(DateTime.parse(purchase['purchase_date']));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              purchase['item_name'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Qty: ${purchase['quantity']}', style: TextStyle(color: Colors.grey[700])),
                Text('Price: ${formatter.format(purchase['purchase_price'])}', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 4),
            Text('Date: $dateFormatted', style: const TextStyle(color: Colors.black54)),
            if (purchase['invoice_no'] != null)
              Text('Invoice: ${purchase['invoice_no']}', style: const TextStyle(color: Colors.black54)),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
                tooltip: 'Delete Purchase',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
