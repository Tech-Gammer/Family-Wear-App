//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
// import '../../../ip_address.dart';
// import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
// import '../Cart_Screen/Cart_provider.dart';
//
// class CheckoutPage extends StatelessWidget {
//   final List<CartItem> cartItems;
//
//   const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);
//     final profileProvider = Provider.of<ProfileProvider>(context);
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);
//
//
//
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Checkout'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             Text(
//               'Customer Details',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Card(
//               child: ListTile(
//                 // leading: Icon(Icons.person),
//                 leading: CircleAvatar(
//                   radius: 30,
//                   backgroundImage: profileProvider.profileImageFile != null ? FileImage(profileProvider.profileImageFile!) : profileProvider.profileImageUrl != null ? NetworkImage(profileProvider.profileImageUrl!) : null,
//                   backgroundColor: Colors.grey[300],
//                   child: profileProvider.profileImageFile == null && profileProvider.profileImageUrl == null ? const Icon(Icons.person, size: 70, color: Colors.red) : null,
//                 ),
//                 title: Text(userProvider.name ?? 'No Name'),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(userProvider.email ?? 'No Email'),
//                     Text(userProvider.address ?? 'No Address'),
//                     Text(userProvider.postalCode ?? 'No Postal Code'),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Your Items',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             ...cartItems.map((item) => ListTile(
//               leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
//               title: Text(item.title),
//               subtitle: Text('Qty: ${item.quantity} x PKR ${item.price.toStringAsFixed(2)}'),
//               trailing: Text('PKR ${(item.price * item.quantity).toStringAsFixed(2)}'),
//             )),
//             Divider(thickness: 2),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Total:',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                 Text(
//                   'PKR ${_calculateTotal(cartItems).toStringAsFixed(2)}',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: () {},
//               child: Text('Place Order', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   double _calculateTotal(List<CartItem> items) {
//     return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../../HomeScreen.dart';
import '../Cart_Screen/Cart_provider.dart';
import '../OrdersScreens/OrdersListPage.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isLoading = false;
  String _paymentMethod = 'Cash on Delivery';
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _addressController.text = userProvider.address ?? '';
    _postalCodeController.text = userProvider.postalCode ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Prepare order items data
    final items = widget.cartItems.map((item) => {
      'item_id': item.itemId,
      'quantity': item.quantity,
      'price': item.price
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/place-order'),
          // final url = "http://${NetworkConfig().ipAddress}:5000/items";

    headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userProvider.userId,
          'items': json.encode(items),
          'total_amount': _calculateTotal(widget.cartItems),
          'shipping_address': _addressController.text,
          'payment_method': _paymentMethod
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Order successfully placed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
        final userId = Provider.of<UserProvider>(context, listen: false).userId.toString();

        // Refresh cart (it should be empty now as the cart was cleared on the server)
        await cartProvider.fetchCartItems(userId: userId);

        // Navigate to orders page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        // Show error
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['message'] ?? 'Failed to place order')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Customer Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Card(
                child: ListTile(
                  // leading: CircleAvatar(
                  //   radius: 30,
                  //   backgroundImage: profileProvider.profileImageFile != null
                  //       ? FileImage(profileProvider.profileImageFile!)
                  //       : profileProvider.profileImageUrl != null
                  //       ? NetworkImage(profileProvider.profileImageUrl!)
                  //       : null,
                  //   backgroundColor: Colors.grey[300],
                  //   child: profileProvider.profileImageFile == null &&
                  //       profileProvider.profileImageUrl == null
                  //       ? const Icon(Icons.person, size: 30, color: Colors.red)
                  //       : null,
                  // ),
                  title: Text(userProvider.name ?? 'No Name'),
                  subtitle: Text(userProvider.email ?? 'No Email'),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Shipping Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your postal code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              RadioListTile<String>(
                title: Text('Cash on Delivery'),
                value: 'Cash on Delivery',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              // RadioListTile<String>(
              //   title: Text('Online Payment'),
              //   value: 'Online Payment',
              //   groupValue: _paymentMethod,
              //   onChanged: (value) {
              //     setState(() {
              //       _paymentMethod = value!;
              //     });
              //   },
              // ),
              SizedBox(height: 20),
              Text(
                'Your Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...widget.cartItems.map((item) => ListTile(
                leading: Image.network(item.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(item.title),
                subtitle: Text(
                    'Qty: ${item.quantity} x PKR ${item.price.toStringAsFixed(2)}'),
                trailing: Text(
                    'PKR ${(item.price * item.quantity).toStringAsFixed(2)}'),
              )),
              Divider(thickness: 2),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(
                    'PKR ${_calculateTotal(widget.cartItems).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _placeOrder,
                child: Text('Place Order', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}