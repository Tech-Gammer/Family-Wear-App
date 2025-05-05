import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../../2_Assets/Colors/Colors_Scheme.dart';
import '../Category_Management/addCategory.dart';
import 'addItem_provider.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {

  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    Provider.of<AddItemProvider>(context, listen: false).fetchCategories(); // Fetch categories when page loads
    Provider.of<AddItemProvider>(context, listen: false).fetchUnits(); // Fetch units when page loads
  }

  void calculateTaxAndNetPrice() {
    final provider = Provider.of<AddItemProvider>(context, listen: false);

    // Get values from controllers, default to 0 if empty
    double taxPercent = double.tryParse(provider.taxPercentController.text) ?? 0;
    double salePrice = double.tryParse(provider.salePriceController.text) ?? 0;

    // Calculate tax amount
    double taxAmount = (taxPercent / 100) * salePrice;
    provider.taxPriceController.text = taxAmount.toStringAsFixed(2);

    // Calculate net price (sale price + tax)
    double netPrice = salePrice + taxAmount;
    provider.netPriceController.text = netPrice.toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final provider = Provider.of<AddItemProvider>(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
        //backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Save Item Details",
        backgroundColor: AppColors.primaryColor,

        /*onPressed: () {
          if (_images.isEmpty || !_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please add at least one image")),
            );
            return;
          }
        },*/

        onPressed: () {
          if (_formKey.currentState!.validate()) {
            provider.uploadItem(context);
          }
        },
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  //onTap: pickImages,
                  onTap: provider.pickImages,
                  child: ImagePickerWidget(images: provider.images, removeImage: provider.removeImage),
                ),

                SizedBox(height: screenHeight * 0.02),
                buildTextField(label: "Item Name", controller: provider.itemNameController, lines: 1),
                buildTextField(label: "Description", controller: provider.descriptionController, lines: 2),
                Row(
                  children: [
                    Expanded(
                      //flex: ,
                      child: DropdownButtonFormField<String>(
                        value: provider.selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: provider.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category["name"],
                            child: Text(category["name"]),
                          );
                        }).toList(),
                        onChanged: provider.setCategory,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField(label: "Quantity", controller: provider.minQuantityController, keyboardType: TextInputType.number, lines: 1)),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: provider.selectedUnit,
                        decoration: InputDecoration(
                          labelText: "Unit",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: provider.quantityUnit.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit["name"],
                            child: Text(unit["name"]),
                          );
                        }).toList(),
                        onChanged: provider.setUnit,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField(label: "Sale Price", controller: provider.salePriceController, keyboardType: TextInputType.number, lines: 1, onChanged: (value) {calculateTaxAndNetPrice();})),
                    SizedBox(width: 10),
                    Expanded(child: buildTextField(label: "Purchase Price", controller: provider.purchasePriceController, keyboardType: TextInputType.number, lines: 1)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField(label: "Tax in %", controller: provider.taxPercentController, keyboardType: TextInputType.number, lines: 1, onChanged: (value)=> calculateTaxAndNetPrice())),
                    SizedBox(width: 10),
                    Expanded(child: buildTextField(label: "Tax in Price", controller: provider.taxPriceController, keyboardType: TextInputType.number, lines: 1, readOnly: true)),
                  ],
                ),
                buildTextField(label: "Net Price", controller: provider.netPriceController, keyboardType: TextInputType.number, lines: 1, readOnly: true,),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required int lines,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: lines,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

}

class ImagePickerWidget extends StatefulWidget {
  final List<File> images;
  final Function(int) removeImage;

  const ImagePickerWidget({required this.images, required this.removeImage, super.key});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}


class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _removeImage(int index) {
    setState(() {
      widget.removeImage(index);
      if (_currentIndex >= widget.images.length) {
        _currentIndex = widget.images.isNotEmpty ? widget.images.length - 1 : 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          height: screenHeight * 0.3,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: widget.images.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: screenWidth * 0.1, color: Colors.grey[600]),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "Tap to add images (1-8)",
                  style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.04),
                ),
              ],
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.file(
                  widget.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
        ),
        if (widget.images.isNotEmpty)
          Positioned(
            top: screenHeight * 0.01,
            right: screenWidth * 0.02,
            child: GestureDetector(
              onTap: () => _removeImage(_currentIndex),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.01),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: AppColors.primaryColor, size: screenWidth * 0.05),
              ),
            ),
          ),
        if (widget.images.isNotEmpty)
          Positioned(
            bottom: screenHeight * 0.01,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: SizedBox(
              height: screenHeight * 0.06,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        _pageController.jumpToPage(index);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentIndex == index ? AppColors.primaryColor.withOpacity(0.5) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          widget.images[index],
                          width: screenWidth * 0.12,
                          height: screenHeight * 0.08,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

