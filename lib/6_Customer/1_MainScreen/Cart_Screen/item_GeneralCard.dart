// import 'package:flutter/material.dart';
//
// class ItemCard extends StatelessWidget {
//   final String imagePath;
//   final String itemName;
//   final String itemPrice;
//   final VoidCallback onTap;
//
//   const ItemCard({
//     super.key,
//     required this.imagePath,
//     required this.itemName,
//     required this.itemPrice,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return GestureDetector(
//       onTap: onTap, // Handle card tap
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Item Image
//             Container(
//               height: screenHeight * 0.2,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//                 image: DecorationImage(
//                   image: AssetImage(imagePath),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Item Name
//                   Text(
//                     itemName,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: screenHeight * 0.02,
//                     ),
//                   ),
//                   SizedBox(height: screenHeight * 0.005),
//                   // Item Price
//                   Text(
//                     itemPrice,
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontSize: screenHeight * 0.018,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }