
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../Cart_Screen/Cart_provider.dart';

class CheckoutPage extends StatelessWidget {
  final List<CartItem> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Customer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(userProvider.name ?? 'No Name'),
                subtitle: Text(userProvider.email ?? 'No Email'),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...cartItems.map((item) => ListTile(
              leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
              title: Text(item.title),
              subtitle: Text('Qty: ${item.quantity} x PKR ${item.price.toStringAsFixed(2)}'),
              trailing: Text('PKR ${(item.price * item.quantity).toStringAsFixed(2)}'),
            )),
            Divider(thickness: 2),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  'PKR ${_calculateTotal(cartItems).toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // You can place the order logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed successfully!')),
                );
                Navigator.pop(context); // Go back to the cart screen or home
              },
              child: Text('Place Order', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}
