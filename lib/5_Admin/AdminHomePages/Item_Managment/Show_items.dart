import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*class ShowItemPage extends StatefulWidget {
  @override
  _ShowItemPageState createState() => _ShowItemPageState();
}

class _ShowItemPageState extends State<ShowItemPage> {
*//*
  @override
  void initState() {
    super.initState();
    Provider.of<ShowItemProvider>(context, listen: false).fetchItems();
  }

*//*

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ShowItemProvider>(context, listen: false);
    provider.fetchItems();
    provider.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShowItemProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Show Items"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: provider.categories.map<Widget>((categoryId) {
                  final isSelected = categoryId == provider.selectedCategory;
                  return ChoiceChip(
                    label: Text("Category $categoryId"),
                    selected: isSelected,
                    onSelected: (_) {
                      provider.setSelectedCategory(
                        isSelected ? null : categoryId,
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final item = provider.items[index];
                  List<String> images = item['item_image']; // Multiple images list

                  return Stack(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            Stack(
                              children: [
                                Container(
                                  height: screenHeight * 0.2,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(item.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: PageView.builder(
                                    itemCount: images.length,
                                    itemBuilder: (context, imgIndex) {
                                      return Image.network(images[imgIndex],
                                          fit: BoxFit.cover);
                                    },
                                  ),
                                ),
                                // Optional: Add a gradient overlay for text readability
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.2),
                                          Colors.black.withOpacity(0.0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row for Name and Price
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Item Name
                                      Expanded(
                                        child: Text(
                                          item['item_name'],
                                          overflow: TextOverflow.ellipsis,
                                          // Handle text overflow
                                          maxLines: 1,
                                          // Limit to a single line
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: screenHeight * 0.018,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Price
                                      Text(
                                        "${item['sale_price']} Pkr",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: screenHeight * 0.016,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.001),
                                  // Item Description
                                  Text(
                                    item['item_description'],
                                    overflow: TextOverflow.ellipsis,
                                    // Handle text overflow
                                    maxLines: 1,
                                    // Limit description to 2 lines
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenHeight * 0.015,
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.005),
                                  // Row for Item Sold and Rating
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Sold Items
                                      Text(
                                        "${item['minimum_qty']} Quantity",
                                        //item['minimum_qty'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          //color: isDarkTheme ? AppColors.lightBackgroundColor : AppColors.darkTextColor,
                                          fontSize: screenHeight * 0.015,
                                        ),
                                      ),

//*
//Rating Stars
                                      *//* Row(
                                        children: List.generate(5, (index) {
                                          if (index < item.rating.floor()) {
                                            // Full star
                                            return Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                              size: screenHeight * 0.02,
                                            );
                                          } else if (index < item.rating) {
                                            // Half star
                                            return Icon(
                                              Icons.star_half,
                                              color: Colors.orange,
                                              size: screenHeight * 0.02,
                                            );
                                          } else {
                                            // Empty star
                                            return Icon(
                                              Icons.star_border,
                                              color: Colors.orange,
                                              size: screenHeight * 0.02,
                                            );
                                          }
                                        }),
                                      ),*//*
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

/*Scaffold(
      appBar: AppBar(title: Text("Items List")),
      body: provider.items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final item = provider.items[index];
          List<String> images = item['item_image'];  // Multiple images list

          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, imgIndex) {
                      return Image.network(images[imgIndex], fit: BoxFit.cover);
                    },
                  ),
                ),
                ListTile(
                  title: Text(item['item_name']),
                  subtitle: Text(item['item_description']),
                  trailing: Text("${item['sale_price']}Pkr"),
                ),
              ],
            ),
          );
        },
      ),
    )*/ */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/ShowItem_Provider.dart';

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
    provider.fetchUnits();  // Fetch units before the page is built
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShowItemProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Show Items"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: provider.categories.map((category) {
                    final isSelected = provider.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) => provider.setSelectedCategory(
                            isSelected ? null : category),
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Colors.grey[300],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Item Grid
          Expanded(
            child: provider.items.isEmpty
                ? Center(child: Text("No items found"))
                : GridView.builder(
              padding: const EdgeInsets.all(4),
              itemCount: provider.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) {
                final item = provider.items[index];
                final images = item['item_image'] as List<String>;

                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailPage(item: Map<String, dynamic>.from(item)),
                      ),
                    );
                  },
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(
                        padding: EdgeInsets.all(16),
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete Item'),
                              onTap: () async {
                                Navigator.pop(context); // close bottom sheet
                                final confirmed = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text("Confirm Delete"),
                                    content: Text("Are you sure you want to delete '${item['item_name']}'?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Delete", style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  final provider = Provider.of<ShowItemProvider>(context, listen: false);
                                  await provider.deleteItem(item['item_id']);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          child: SizedBox(
                            height: screenHeight * 0.2,
                            child: PageView.builder(
                              itemCount: images.length,
                              itemBuilder: (_, i) =>
                                  Image.network(images[i], fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['item_name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenHeight * 0.018),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "${item['net_price']} PKR",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenHeight * 0.016,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5),
                              Text(
                                item['item_description'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: screenHeight * 0.015),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Remaining Quantity ${item['minimum_qty']} ",
                                style: TextStyle(
                                  fontSize: screenHeight * 0.014,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

