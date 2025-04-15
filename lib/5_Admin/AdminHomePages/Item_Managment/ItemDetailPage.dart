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
                              /*const SizedBox(width: 10),
                              Text(
                                "${widget.item['net_price']} PKR",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),*/
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
