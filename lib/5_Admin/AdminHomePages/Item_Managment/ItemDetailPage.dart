/*
import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'ShowItem_Provider.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final PageController _pageController = PageController();
  bool _showFullName = false;

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.item['item_image'] ?? [];
    final theme = Theme.of(context);
    final provider = Provider.of<ShowItemProvider>(context);

    // Get the category name from the categories list using the category_id
    String categoryName = '';
    if (widget.item['category_id'] != null) {
      // Find the category name matching the category_id
      categoryName = provider.categories
          .firstWhere(
            (category) => category.id == widget.item['category_id'],
        orElse: () => Category(id: null, name: 'Unknown Category'),
      ).name;
    }

    // Get the unit name from the units list using the unit_id
    String unitName = '';
    if (widget.item['unit_id'] != null) {
      unitName = provider.units
          .firstWhere(
            (unit) => unit.id == widget.item['unit_id'],
        orElse: () => Unit(id: null, name: 'Unknown Unit'),
      ).name;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Item Detail'),
        centerTitle: true,
        //backgroundColor: Colors.deepPurple,
        //foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Hero(
                              //tag: 'itemImage-${widget.item['item_id'] ?? widget.item['item_name']}',
                              tag: 'itemImage-${widget.item['item_id']}-${index}',
                              child: Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: images.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.primaryColor,
                        dotColor: Colors.white,
                        dotHeight: 10,
                        dotWidth: 10,
                        expansionFactor: 3,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // Main Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Price with toggle full name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFullName = !_showFullName;
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.item['item_name'] ?? '',
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                                  overflow: _showFullName ? TextOverflow.visible : TextOverflow.ellipsis,
                                  maxLines: _showFullName ? null : 1,
                                ),
                              ),
                              */
/*const SizedBox(width: 10),
                              Text(
                                "${widget.item['net_price']} PKR",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),*//*

                            ],
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "Price: ${widget.item['net_price']} PKR",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.black.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text("Description", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 6),
                    Text(
                      widget.item['item_description'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // Other Details
                    Text("Other Details", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 5,
                      //runSpacing: 0,
                      children: [
                        //DetailChip(label: 'Unit', value: widget.item['unit_id'].toString()),
                        DetailChip(
                          label: 'Unit Name',
                          value: '${unitName[0].toUpperCase()}${unitName.substring(1).toLowerCase()}',
                        ),
                        DetailChip(
                          label: 'Category',
                          value: '${categoryName[0].toUpperCase()}${categoryName.substring(1).toLowerCase()}',
                        ),
                        DetailChip(label: 'Purchase Price', value: widget.item['purchase_price'].toString()),
                        DetailChip(label: 'Sale Price', value: widget.item['sale_price'].toString()),
                        DetailChip(label: 'Tax (%)', value: widget.item['tax_in_percent'].toString()),
                        DetailChip(label: 'Tax (Amt)', value: widget.item['tax_in_amount'].toString()),
                        DetailChip(label: 'Net Price', value: widget.item['net_price'].toString()),
                        DetailChip(label: 'Remaining Qty', value: widget.item['minimum_qty'].toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class DetailChip extends StatelessWidget {
  final String label;
  final String value;

  const DetailChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      backgroundColor: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
*/


import 'package:family_wear_app/2_Assets/Colors/Colors_Scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'ShowItem_Provider.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final PageController _pageController = PageController();
  bool _showFullName = false;

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.item['item_image'] ?? [];
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final provider = Provider.of<ShowItemProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final imageHeight = screenHeight * 0.35;
    final horizontalPadding = screenWidth > 600 ? 24.0 : 12.0;
    final titleFontSize = screenWidth > 600 ? 24.0 : 20.0;
    final detailFontSize = screenWidth > 600 ? 16.0 : 14.0;
    final priceFontSize = screenWidth > 600 ? 24.0 : 20.0;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    // Get the category name from the categories list using the category_id
    String categoryName = '';
    if (widget.item['category_id'] != null) {
      categoryName = provider.categories
          .firstWhere(
            (category) => category.id == widget.item['category_id'],
        orElse: () => Category(id: null, name: 'Unknown Category'),
      ).name;
    }

    // Get the unit name from the units list using the unit_id
    String unitName = '';
    if (widget.item['unit_id'] != null) {
      unitName = provider.units.firstWhere(
            (unit) => unit.id == widget.item['unit_id'],
        orElse: () => Unit(id: null, name: 'Unknown Unit'),
      ).name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Details',
          style: TextStyle(
            fontSize: titleFontSize * 0.8,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.lightTextColor : AppColors.darkTextColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? AppColors.darkBackgroundColor  : AppColors.lightTextColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.lightTextColor : AppColors.darkTextColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery Section
            if (images.isNotEmpty)
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkBackgroundColor.withOpacity(0.5) : AppColors.background,
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(screenWidth * 0.00),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Hero(
                              tag: 'itemImage-${widget.item['item_id']}-${index}',
                              child: Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryColor,
                                      ),
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 20,
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: images.length,
                        effect: ScrollingDotsEffect(
                          activeDotColor: AppColors.primaryColor,
                          dotColor: isDarkMode
                              ? AppColors.lightTextColor.withOpacity(0.4)
                              : AppColors.darkTextColor.withOpacity(0.4),
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showFullName = !_showFullName;
                                });
                              },
                              child: Text(
                                widget.item['item_name'] ?? '',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? AppColors.lightTextColor
                                      : AppColors.darkTextColor,
                                ),
                                overflow: _showFullName ? TextOverflow.visible : TextOverflow.ellipsis,
                                maxLines: _showFullName ? null : 1,
                              ),
                            ),
                            //const SizedBox(height: 4),
                            /*Text(
                              categoryName.isNotEmpty
                                  ? 'Category: ${categoryName[0].toUpperCase()}${categoryName.substring(1).toLowerCase()}'
                                  : 'No Category',
                              style: TextStyle(
                                fontSize: detailFontSize * 0.9,
                                color: isDarkMode
                                    ? AppColors.lightTextColor.withOpacity(0.7)
                                    : AppColors.darkTextColor.withOpacity(0.7),
                              ),
                            ),*/

                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          "${widget.item['net_price']} PKR",
                          style: TextStyle(
                            fontSize: detailFontSize,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Description Section
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: titleFontSize * 0.85,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppColors.lightTextColor
                          : AppColors.darkTextColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.darkBackgroundColor.withOpacity(0.5)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.item['item_description']?.isNotEmpty == true
                          ? widget.item['item_description']!
                          : 'No description available',
                      style: TextStyle(
                        fontSize: detailFontSize,
                        color: isDarkMode
                            ? AppColors.lightTextColor.withOpacity(0.8)
                            : AppColors.darkTextColor.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Details Section
                  Text(
                    "Product Details",
                    style: TextStyle(
                      fontSize: titleFontSize * 0.85,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? AppColors.lightTextColor
                          : AppColors.darkTextColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: screenWidth > 600 ? 3.5 : 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildDetailItem(
                        context,
                        "Unit",
                        '${unitName[0].toUpperCase()}${unitName.substring(1).toLowerCase()}',
                        Icons.straighten,
                        detailFontSize,
                      ),

                      _buildDetailItem(
                        context,
                        "Category",
                        '${categoryName[0].toUpperCase()}${categoryName.substring(1).toLowerCase()}',
                        Icons.category,
                        detailFontSize,
                      ),
                      _buildDetailItem(
                        context,
                        "Purchase Price",
                        widget.item['purchase_price'].toString(),
                        Icons.attach_money,
                        detailFontSize,
                      ),
                      _buildDetailItem(
                        context,
                        "Sale Price",
                        widget.item['sale_price'].toString(),
                        Icons.sell,
                        detailFontSize,
                      ),
                      _buildDetailItem(
                        context,
                        "Tax (%)",
                        widget.item['tax_in_percent'].toString(),
                        Icons.percent,
                        detailFontSize,
                      ),
                      _buildDetailItem(
                        context,
                        "Tax Amount",
                        widget.item['tax_in_amount'].toString(),
                        Icons.money,
                        detailFontSize,
                      ),
                      _buildDetailItem(
                        context,
                        "Stock Qty",
                        widget.item['minimum_qty'].toString(),
                        Icons.inventory,
                        detailFontSize,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      double fontSize,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkBackgroundColor.withOpacity(0.7)
            : AppColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDarkMode
              ? AppColors.primaryColor.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: fontSize * 1.2,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    color: isDarkMode
                        ? AppColors.lightTextColor.withOpacity(0.6)
                        : AppColors.darkTextColor.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppColors.lightTextColor
                        : AppColors.darkTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}