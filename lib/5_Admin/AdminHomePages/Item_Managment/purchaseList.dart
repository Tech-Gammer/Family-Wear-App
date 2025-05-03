import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'purchase_provider.dart';

class PurchaseListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Purchase History')),
      body: FutureBuilder(
        future: Provider.of<PurchaseProvider>(context, listen: false).fetchPurchases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Consumer<PurchaseProvider>(
            builder: (context, provider, _) {
              return ListView.builder(
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
        title: Text('Confirm Delete'),
        content: Text('This will deduct ${purchase['quantity']} from item stock. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deletePurchase(purchase['purchase_id']);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase deleted successfully')),
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(purchase['item_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qty: ${purchase['quantity']}'),
            Text('Price: \$${purchase['purchase_price']}'),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(purchase['purchase_date']))}'),
            if (purchase['invoice_no'] != null) Text('Invoice: ${purchase['invoice_no']}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}