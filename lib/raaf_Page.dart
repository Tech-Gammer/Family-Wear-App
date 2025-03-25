import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Raaf extends StatefulWidget {
  @override
  _RaafState createState() => _RaafState();
}

class _RaafState extends State<Raaf> {

  final Map<String, String> itemImages = {
    "Woman Sweater": "asset/dress.jpg",
    "Smart Watch": "asset/q2.png",
    "Wireless Headphone": "asset/shoes.jpg",
  };

  List<Map<String, dynamic>> cartItems = [
    {"title": "Woman Sweater", "category": "Woman Fashion", "price": 70.00, "quantity": 1},
    {"title": "Smart Watch", "category": "Electronics", "price": 55.00, "quantity": 1},
    {"title": "Wireless Headphone", "category": "Electronics", "price": 120.00, "quantity": 1},
  ];

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] = (cartItems[index]['quantity'] + change).clamp(1, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        //appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
        backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : AppColors.lightBackgroundColor,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              child: Text("My Cart Products",
                style: TextStyle(
                  fontSize: screenHeight * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Slidable(
                        key: ValueKey(index),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _removeItem(index),
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(itemImages[item['title']]!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['category']),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('\$${item['price'].toStringAsFixed(2)}'),
                                  Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, size: 15),
                                          onPressed: () => _updateQuantity(index, -1),
                                        ),
                                        Text('${item['quantity']}', style: const TextStyle(fontSize: 15)),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 15),
                                          onPressed: () => _updateQuantity(index, 1),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter Discount Code',
                      suffixIcon: TextButton(
                        onPressed: () {},
                        child: const Text('Apply', style: TextStyle(color: AppColors.primaryColor)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 16)),
                      Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    child: const Text('Checkout', style: TextStyle(color: AppColors.lightTextColor)),
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
