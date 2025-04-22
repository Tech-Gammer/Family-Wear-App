// import 'package:flutter/material.dart';
//
// class roughpage extends StatefulWidget {
//   const roughpage({super.key});
//
//   @override
//   State<roughpage> createState() => _roughpageState();
// }
//
// class _roughpageState extends State<roughpage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           GridView.builder(
//   shrinkWrap: true,
//   physics: const NeverScrollableScrollPhysics(),
//   itemCount: items.length,
//   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//     crossAxisCount: 2,
//     crossAxisSpacing: 16,
//     mainAxisSpacing: 16,
//     childAspectRatio: 3 / 4,
//   ),
//   itemBuilder: (context, index) {
//     final item = items[index];
//     return Stack(
//       children: [
//         Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Image Section
//               Stack(
//                 children: [
//                   Container(
//                     height: screenHeight * 0.2,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(12),
//                         topRight: Radius.circular(12),
//                       ),
//                       image: DecorationImage(
//                         image: AssetImage(item.image),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   // Optional: Add a gradient overlay for text readability
//                   Positioned.fill(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.black.withOpacity(0.2),
//                             Colors.black.withOpacity(0.0),
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Row for Name and Price
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Item Name
//                         Expanded(
//                           child: Text(
//                             item.name,
//                             overflow: TextOverflow.ellipsis, // Handle text overflow
//                             maxLines: 1, // Limit to a single line
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: screenHeight * 0.015,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.005),
//                         // Price
//                         Text(
//                           item.price,
//                           textAlign: TextAlign.right,
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontSize: screenHeight * 0.015,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: screenHeight * 0.0005),
//                     // Item Description
//                     Text(
//                       item.description,
//                       overflow: TextOverflow.ellipsis, // Handle text overflow
//                       maxLines: 1, // Limit description to 2 lines
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: screenHeight * 0.015,
//                       ),
//                     ),
//
//                     SizedBox(height: screenHeight * 0.0005),
//                     // Row for Item Sold and Rating
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Sold Items
//                         Text(
//                           '${item.soldItem} Sold',
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkTextColor,
//                             fontSize: screenHeight * 0.01,
//                           ),
//                         ),
//
//                         // Rating Stars
//                         Row(
//                           children: List.generate(5, (index) {
//                             if (index < item.rating.floor()) {
//                               // Full star
//                               return Icon(
//                                 Icons.star,
//                                 color: Colors.orange,
//                                 size: screenHeight * 0.015,
//                               );
//                             } else if (index < item.rating) {
//                               // Half star
//                               return Icon(
//                                 Icons.star_half,
//                                 color: Colors.orange,
//                                 size: screenHeight * 0.015,
//                               );
//                             } else {
//                               // Empty star
//                               return Icon(
//                                 Icons.star_border,
//                                 color: Colors.orange,
//                                 size: screenHeight * 0.015,
//                               );
//                             }
//                           }),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Favorite Icon with Curved Background and Border
//         Positioned(
//           top: 0,
//           right: 0,
//           child: Consumer<ItemProvider>(
//             builder: (context, itemProvider, child) {
//               return GestureDetector(
//                 onTap: () => itemProvider.toggleFavorite(index), // Toggle favorite state
//                 child: Stack(
//                   children: [
//                     // Outer Clip for the Border
//                     ClipPath(
//                       clipper: TopRightCurveClipper(),
//                       child: Container(
//                         color: Colors.green, // Border color
//                         padding: const EdgeInsets.all(10), // Padding to create a border effect
//                       ),
//                     ),
//
//                     // Inner Clip for the Icon Background
//                     ClipPath(
//                       clipper: TopRightCurveClipper(),
//                       child: Container(
//                         color: item.isFavorite ? AppColors.primaryColor : AppColors.lightBackgroundColor, // Dynamic background color
//                         padding: const EdgeInsets.all(8), // Padding for the icon
//                         child: Icon(
//                           item.isFavorite ? Icons.favorite : Icons.favorite_border,
//                           color: item.isFavorite ? AppColors.lightBackgroundColor : Colors.black,
//                           size: screenHeight * 0.03,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//
//       ],
//     );
//   },
// ),
//
//         ],
//       ),
//     );
//   }
// }
