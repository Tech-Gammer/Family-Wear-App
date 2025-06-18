
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../1_Auth/Intro/Intro_Providers/Profile_Provider.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../../HomeScreen.dart';
import '../Cart_Screen/Cart_provider.dart';
import '../OrdersScreens/OrdersListPage.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

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
    Stripe.publishableKey = 'pk_test_51OD3ACBJHKRP32EvgnNMZ5aXKW69v0kMwUEolRC4axL4pRli8Qcaa9uPPc7A1A8kNbIQ5vhPEIg7XREWtZkuOgk7004j90qxTP'; // Add your Stripe publishable key

  }

  @override
  void dispose() {
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Create payment intent on your server
      final response = await http.post(
        Uri.parse('http://${NetworkConfig().ipAddress}:5000/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (_calculateTotal(widget.cartItems) * 100).toInt(), // Convert to cents
          'currency': 'PKR',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }

      final paymentIntentData = json.decode(response.body);

      // 2. Initialize payment sheet with customer details
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'Your Store',
          customerId: paymentIntentData['customer'],
          customerEphemeralKeySecret: paymentIntentData['ephemeralKey'],
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.green,
              background: Colors.white,
              componentText: Colors.grey[200]!,
              componentBorder: Colors.grey,
              componentDivider: Colors.grey,
            ),
          ),
        ),
      );

      // 3. Display the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. If successful, place the order with payment details
      await _placeOrder({
        'payment_intent': paymentIntentData['paymentIntent'],
        'payment_method': 'card',
        'amount': _calculateTotal(widget.cartItems),
        'currency': 'pkr',
      });

    } on StripeException catch (e) {
      // Handle Stripe-specific errors
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Future<void> _placeOrder() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);
  //   final cartProvider = Provider.of<CartProvider>(context, listen: false);
  //
  //   // Prepare order items data
  //   final items = widget.cartItems.map((item) => {
  //     'item_id': item.itemId,
  //     'quantity': item.quantity,
  //     'price': item.price
  //   }).toList();
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://${NetworkConfig().ipAddress}:5000/place-order'),
  //         // final url = "http://${NetworkConfig().ipAddress}:5000/items";
  //
  //   headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'user_id': userProvider.userId,
  //         'items': json.encode(items),
  //         'total_amount': _calculateTotal(widget.cartItems),
  //         'shipping_address': _addressController.text,
  //         'payment_method': _paymentMethod
  //       }),
  //     );
  //
  //     setState(() => _isLoading = false);
  //
  //     if (response.statusCode == 201) {
  //       final responseData = json.decode(response.body);
  //       // Order successfully placed
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Order placed successfully!')),
  //       );
  //       final userId = Provider.of<UserProvider>(context, listen: false).userId.toString();
  //
  //       // Refresh cart (it should be empty now as the cart was cleared on the server)
  //       await cartProvider.fetchCartItems(userId: userId);
  //
  //       // Navigate to orders page
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(
  //           builder: (context) => HomeScreen(),
  //         ),
  //       );
  //     } else {
  //       // Show error
  //       final errorData = json.decode(response.body);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(errorData['message'] ?? 'Failed to place order')),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() => _isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   }
  // }

  Future<void> _placeOrder(Map<String, dynamic> paymentDetails) async {
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
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userProvider.userId,
          'items': json.encode(items),
          'total_amount': _calculateTotal(widget.cartItems),
          'shipping_address': _addressController.text,
          'payment_method': _paymentMethod,
          'payment_details': paymentDetails,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        // Order successfully placed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );

        // Refresh cart
        await cartProvider.fetchCartItems(userId: userProvider.userId.toString());

        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
              ListTile(
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
              RadioListTile<String>(
                title: Text('Online Payment'),
                value: 'Online Payment',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                'Your Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...widget.cartItems.map((item) => ListTile(
                leading: Image.network(item.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(item.title),//s
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
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.green,
              //     padding: const EdgeInsets.symmetric(vertical: 15),
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10)),
              //   ),
              //   onPressed: _placeOrder,
              //   child: Text('Place Order', style: TextStyle(color: Colors.white)),
              // ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_paymentMethod == 'Online Payment') {
                    _processPayment();
                  } else {
                    _placeOrder({});
                  }
                },
                child: const Text(
                  'Place Order',
                  style: TextStyle(color: Colors.white),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}