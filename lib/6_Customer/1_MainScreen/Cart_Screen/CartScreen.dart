// import 'package:flutter/material.dart';
//
// void main() => runApp(MaterialApp(home: CartScreen()));
//
// class CartScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> cartItems = [
//     {"title": "Woman Sweater", "category": "Woman Fashion", "price": 70.00, "image": Icons.shopping_bag},
//     {"title": "Smart Watch", "category": "Electronics", "price": 55.00, "image": Icons.watch},
//     {"title": "Wireless Headphone", "category": "Electronics", "price": 120.00, "image": Icons.headset},
//     {"title": "Wireless Headphone", "category": "Electronics", "price": 120.00, "image": Icons.headset},
//     {"title": "Wireless Headphone", "category": "Electronics", "price": 120.00, "image": Icons.headset},
//     {"title": "Wireless Headphone", "category": "Electronics", "price": 120.00, "image": Icons.headset},
//     {"title": "Wireless Headphone", "category": "Electronics", "price": 120.00, "image": Icons.headset},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     double subtotal = cartItems.fold(0, (sum, item) => sum + item['price']);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: cartItems.length,
//               itemBuilder: (context, index) {
//                 final item = cartItems[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   child: ListTile(
//                     leading: Icon(item['image'], size: 40),
//                     title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
//                     subtitle: Text(item['category']),
//                     trailing: Text('\$${item['price'].toStringAsFixed(2)}'),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Enter Discount Code',
//                     suffixIcon: TextButton(
//                       onPressed: () {},
//                       child: const Text('Apply', style: TextStyle(color: Colors.orange)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Subtotal', style: TextStyle(fontSize: 16)),
//                     Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                     Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   onPressed: () {},
//                   child: const Text('Checkout', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

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

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
/*
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(itemImages[item]!)
                  ),
                )
                )
*/
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
/*
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red,size: 5,),
                        onPressed: () => _removeItem(index),
                      ),
*/
                    ],
                  ),                //subtitle: Text(item['category']),
                isThreeLine: true,
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
                                  icon: const Icon(Icons.remove, size: 15,),
                                  onPressed: () => _updateQuantity(index, -1),
                                ),
                                Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,size: 15,),
                                  onPressed: () => _updateQuantity(index, 1),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
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
                      child: const Text('Apply', style: TextStyle(color: Colors.orange)),
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
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {},
                  child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
