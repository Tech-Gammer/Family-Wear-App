import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ItemDetailPage.dart';


class ShowItemPage extends StatefulWidget {
  @override
  _ShowItemPageState createState() => _ShowItemPageState();
}

class _ShowItemPageState extends State<ShowItemPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ShowItemProvider>(context, listen: false);
    provider.fetchItems();
    provider.fetchCategories();
    provider.fetchUnits();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShowItemProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final imageHeight = screenHeight * (screenWidth > 600 ? 0.25 : 0.2);
    final chipSpacing = screenWidth > 600 ? 12.0 : 8.0;
    final titleFontSize = screenWidth > 600 ? 18.0 : 16.0;
    final priceFontSize = screenWidth > 600 ? 16.0 : 14.0;
    final descFontSize = screenWidth > 600 ? 14.0 : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product Inventory",
          style: TextStyle(
            fontSize: titleFontSize * 1.2,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.lightTextColor : AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? AppColors.darkBackgroundColor  : AppColors.lightTextColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color:
          isDarkMode ? AppColors.lightTextColor : AppColors.darkTextColor,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter Chips
          if (provider.categories.isNotEmpty)
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.categories.length + 1,
                separatorBuilder: (_, __) => SizedBox(width: chipSpacing),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ChoiceChip(
                      label: Text(
                        "All Items",
                        style: TextStyle(
                          fontSize: titleFontSize * 0.8,
                          color: provider.selectedCategory == null
                              ? Colors.white
                              : isDarkMode
                              ? AppColors.lightTextColor
                              : AppColors.darkTextColor,
                        ),
                      ),
                      selected: provider.selectedCategory == null,
                      onSelected: (_) => provider.setSelectedCategory(null),
                      selectedColor: AppColors.primaryColor,
                      backgroundColor: isDarkMode
                          ? AppColors.darkBackgroundColor.withOpacity(0.5)
                          : AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                    );
                  }

                  final category = provider.categories[index - 1];
                  final isSelected = provider.selectedCategory == category;

                  return ChoiceChip(
                    label: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: titleFontSize * 0.8,
                        color: isSelected
                            ? Colors.white
                            : isDarkMode
                            ? AppColors.lightTextColor
                            : AppColors.darkTextColor,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => provider
                        .setSelectedCategory(isSelected ? null : category),
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: isDarkMode
                        ? AppColors.darkBackgroundColor.withOpacity(0.5)
                        : AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: AppColors.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Item Grid
          Expanded(
            child: /*provider.isLoading
                ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            )
                : provider.items.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No items found",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      color: isDarkMode
                          ? AppColors.lightTextColor.withOpacity(0.7)
                          : AppColors.darkTextColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
                : */
            GridView.builder(
              padding: EdgeInsets.all(8),
              itemCount: provider.items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final item = provider.items[index];
                final images = item['item_image'] as List<String>;

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemDetailPage(item: Map<String, dynamic>.from(item),),
                        ),
                      );
                    },
                    onLongPress: () => _showItemOptions(context, item),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isDarkMode ? AppColors.darkBackgroundColor.withOpacity(0.7) : Colors.white,
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
                              color: isDarkMode ? AppColors.darkBackgroundColor : AppColors.background,
                              child: images.isEmpty
                                  ? Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: AppColors.primaryColor,
                                ),
                              )
                                  : PageView.builder(
                                itemCount: images.length,
                                itemBuilder: (_, i) => Image.network(
                                  images[i],
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                      Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: AppColors.primaryColor,
                                      ),
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                                    color: isDarkMode ? AppColors.lightTextColor.withOpacity(0.7) : AppColors.darkTextColor.withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.inventory,
                                      size: descFontSize * 1.2,
                                      color: AppColors.primaryColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Remaining Products: ${item['minimum_qty']}",
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(BuildContext context, Map<String, dynamic> item) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBackgroundColor : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Item',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDarkMode
                        ? AppColors.darkBackgroundColor
                        : Colors.white,
                    title: Text(
                      "Confirm Delete",
                      style: TextStyle(
                        color: isDarkMode ? AppColors.lightTextColor : AppColors.darkTextColor,
                      ),
                    ),
                    content: Text(
                      "Are you sure you want to delete '${item['item_name']}'?",
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.lightTextColor.withOpacity(0.8)
                            : AppColors.darkTextColor.withOpacity(0.8),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final provider =
                  Provider.of<ShowItemProvider>(context, listen: false);
                  await provider.deleteItem(item['item_id']);
                }
              },
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primaryColor),
              title: Text(
                'Edit Item',
                style: TextStyle(color: AppColors.primaryColor),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add your edit navigation logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}