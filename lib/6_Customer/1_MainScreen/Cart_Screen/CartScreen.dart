import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../../../ip_address.dart';
import '../../2_CustomerProviders/HomeTabScreen_Provider.dart';
import '../Checkout_Screen/CheckoutScreen.dart';
import 'Cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = Provider.of<UserProvider>(context, listen: false).userId.toString();
      Provider.of<CartProvider>(context, listen: false).fetchCartItems(userId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme
                          ? AppColors.lightTextColor
                          : AppColors.darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to start shopping',
                    style: TextStyle(
                      color: isDarkTheme
                          ? AppColors.lightTextColor
                          : AppColors.darkTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return Dismissible(
                      key: Key(item.itemId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        cartProvider.removeFromCart(item.itemId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.title} removed from cart'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: CartItemWidget(item: item),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartProvider cartProvider) {
    final subtotal = cartProvider.cartItems.fold(
      0.0,
          (sum, item) => sum + (item.price * item.quantity),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TextField(
          //   decoration: InputDecoration(
          //     hintText: 'Enter Discount Code',
          //     suffixIcon: TextButton(
          //       onPressed: () {},
          //       child: const Text('Apply',
          //           style: TextStyle(color: Colors.orange)),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:', style: TextStyle(fontSize: 16)),
              Text(
                'PKR ${subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                'PKR ${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              // backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              //s
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(
                      cartItems: cartProvider.cartItems),
                ),
              );
            },
            child: const Text('Checkout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PKR ${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: AppColors.primaryColor, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 15),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => cartProvider.updateQuantity(
                        item.itemId, -1),
                  ),
                  const SizedBox(width: 8),
                  Text('${item.quantity}',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add, size: 15),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => cartProvider.updateQuantity(
                        item.itemId, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

