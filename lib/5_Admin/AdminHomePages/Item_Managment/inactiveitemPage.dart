// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
//
// class InactiveItemsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ShowItemProvider>(context, listen: false);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Inactive Items"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () => provider.fetchItems(activeOnly: false),
//           ),
//         ],
//       ),
//       body: FutureBuilder(
//         future: provider.fetchItems(activeOnly: false),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           return Consumer<ShowItemProvider>(
//             builder: (context, provider, _) {
//               return ListView.builder(
//                 itemCount: provider.items.length,
//                 itemBuilder: (context, index) {
//                   final item = provider.items[index];
//                   return ListTile(
//                     title: Text(item['item_name']),
//                     subtitle: Text(item['item_description'] ?? ''),
//                     trailing: ElevatedButton(
//                       child: Text('Activate'),
//                       onPressed: () async {
//                         try {
//                           await provider.updateItemStatus(
//                             item['item_id'],
//                             true,
//                           );
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Item activated successfully')),
//                           );
//                           provider.fetchItems(activeOnly: false);
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Error activating item: $e')),
//                           );
//                         }
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';

class InactiveItemsPage extends StatefulWidget {
  const InactiveItemsPage({super.key});

  @override
  State<InactiveItemsPage> createState() => _InactiveItemsPageState();
}

class _InactiveItemsPageState extends State<InactiveItemsPage> {
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();//s
    final provider = Provider.of<ShowItemProvider>(context, listen: false);
    provider.fetchItems(activeOnly: false).then((_) {
      provider.applyFilter(showInactiveOnly: true);
      if (mounted) setState(() => _isLoading = false);
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values (same as ShowItemPage)
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final imageHeight = screenHeight * (screenWidth > 600 ? 0.25 : 0.2);
    final titleFontSize = screenWidth > 600 ? 18.0 : 16.0;
    final priceFontSize = screenWidth > 600 ? 16.0 : 14.0;
    final descFontSize = screenWidth > 600 ? 14.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inactive Items",
          style: TextStyle(
            fontSize: titleFontSize * 1.2,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.lightTextColor : AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? AppColors.darkBackgroundColor : AppColors.lightTextColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.lightTextColor : AppColors.darkTextColor,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              final provider = Provider.of<ShowItemProvider>(context, listen: false);
              await provider.fetchItems(activeOnly: false);
              provider.applyFilter(showInactiveOnly: true); // <- Filter only inactive items
            },

          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<ShowItemProvider>(
        builder: (context, provider, _) {
          return GridView.builder(
            padding: EdgeInsets.all(8),
            itemCount: provider.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.63,
            ),
            itemBuilder: (context, index) {
              final item = provider.items[index];
              final images = item['item_image'] as List<String>;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isDarkMode
                      ? AppColors.darkBackgroundColor.withOpacity(0.7)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      child: Container(
                        height: imageHeight,
                        color: isDarkMode
                            ? AppColors.darkBackgroundColor
                            : AppColors.background,
                        child: images.isEmpty
                            ? Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: AppColors.primaryColor,
                          ),
                        )
                            : Image.network(
                          images[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 50,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    // Product Info
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['item_name'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? AppColors.lightTextColor
                                        : AppColors.darkTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),//s
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "${item['net_price']} PKR",
                                  style: TextStyle(
                                    fontSize: priceFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            item['item_description'] ?? 'No description',
                            style: TextStyle(
                              fontSize: descFontSize,
                              color: isDarkMode
                                  ? AppColors.lightTextColor.withOpacity(0.7)
                                  : AppColors.darkTextColor.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: descFontSize * 0.6,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Remaining: ${item['minimum_qty']}",
                                    style: TextStyle(
                                      fontSize: descFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? AppColors.lightTextColor
                                          : AppColors.darkTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                ),
                                child: Text(
                                  'Activate',
                                  style: TextStyle(
                                    fontSize: descFontSize,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await provider.updateItemStatus(
                                        item['item_id'], true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Item activated successfully')),
                                    );
                                    // provider.fetchItems(activeOnly: false);
                                    provider.applyFilter(showInactiveOnly: true); // <- Filter only inactive items
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error activating item: $e')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

