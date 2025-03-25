/*
import 'package:family_wear_app/5_Admin/AdminHomePages/Category_Management/addCategory.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../2_Assets/Colors/Colors_Scheme.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  String? _selectedCategory;
  List<String> categories = ["Electronics", "Clothing", "Groceries", "Home Decor"]; // Replace with dynamic data

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _taxPercentController = TextEditingController();
  final TextEditingController _taxPriceController = TextEditingController();
  final TextEditingController _netPriceController = TextEditingController();
  final TextEditingController _minQuantityController = TextEditingController();

  Future<void> pickImages() async {
    if (_images.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can only add up to 8 images")),
      );
      return;
    }

    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images.addAll(selectedImages.map((e) => File(e.path)));
        if (_images.length > 8) {
          _images = _images.sublist(0, 8);
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_currentIndex >= _images.length && _currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
        //backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Save Item Details",
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          if (_images.isEmpty || !_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please add at least one image")),
            );
            return;
          }
        },
        child: Text(
          "Save",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: pickImages,
                  child: Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: _images.isEmpty
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
                            itemCount: _images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.file(
                                _images[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          ),
                        ),
                      ),
                      if (_images.isNotEmpty)
                        Positioned(
                          top: screenHeight * 0.01,
                          right: screenWidth * 0.02,
                          child: GestureDetector(
                            onTap: () => removeImage(_currentIndex),
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
                      if (_images.isNotEmpty)
                        Positioned(
                          bottom: screenHeight * 0.01,
                          left: screenWidth * 0.05, // Adjusted left position
                          right: screenWidth * 0.05, // Adjusted right position
                          child: Container(
                            height: screenHeight * 0.06,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              controller: ScrollController(initialScrollOffset: _currentIndex * (screenWidth * 0.14)), // Scroll to the selected image
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentIndex = index;
                                      _pageController.animateToPage(
                                        index,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _currentIndex == index ? AppColors.primaryColor : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _images[index],
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
                  ),
                ),
               // SizedBox(height: screenHeight * 0.02),
                SizedBox(height: screenHeight * 0.02),
                buildTextField(label: "Item Name", controller: _itemNameController, lines: 1),
                buildTextField(label: "Description", controller: _descriptionController, lines: 2),
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddCategory()),
                          ).then((newCategory) {
                            if (newCategory != null) {
                              setState(() {
                                categories.add(newCategory);
                                _selectedCategory = newCategory;
                              });
                            }
                          });
                        },
                        child: Icon(Icons.add_circle_outline_rounded, size: 30, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField(label: "Sale Price", controller: _salePriceController, keyboardType: TextInputType.number, lines: 1)),
                    SizedBox(width: 10),
                    Expanded(child: buildTextField(label: "Purchase Price", controller: _purchasePriceController, keyboardType: TextInputType.number, lines: 1)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField(label: "Tax in %", controller: _taxPercentController, keyboardType: TextInputType.number, lines: 1)),
                    SizedBox(width: 10),
                    Expanded(child: buildTextField(label: "Tax in Price", controller: _taxPriceController, keyboardType: TextInputType.number, lines: 1)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField(label: "Net Price", controller: _netPriceController, keyboardType: TextInputType.number, lines: 1)),
                    SizedBox(width: 10),
                    Expanded(child: buildTextField(label: "Minimum Quantity", controller: _minQuantityController, keyboardType: TextInputType.number, lines: 1)),
                  ],
                ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: lines,
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


*/


// second page check

/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../2_Assets/Colors/Colors_Scheme.dart';
import 'package:family_wear_app/5_Admin/AdminHomePages/Category_Management/addCategory.dart';

import 'addItem_provider.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  String? _selectedCategory;
  List<String> categories = ["Electronics", "Clothing", "Groceries", "Home Decor"];

  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _taxPercentController = TextEditingController();
  final _taxPriceController = TextEditingController();
  final _netPriceController = TextEditingController();
  final _minQuantityController = TextEditingController();

  Future<void> pickImages() async {
    if (_images.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only add up to 8 images")),
      );
      return;
    }

    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images.addAll(selectedImages.map((e) => File(e.path)));
        if (_images.length > 8) {
          _images = _images.sublist(0, 8);
        }
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_currentIndex >= _images.length && _currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final provider = Provider.of<AddItemProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Save Item Details",
        backgroundColor: AppColors.primaryColor,
        onPressed: () => provider.uploadItem(context),
        child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                  onTap: provider.pickImages,
                  child: ImagePickerWidget(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    images: _images,
                    currentIndex: _currentIndex,
                    pageController: _pageController,
                    removeImage: removeImage,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                buildTextField("Item Name", _itemNameController),
                buildTextField("Description", _descriptionController, lines: 2),
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: categories.map((String category) {
                          return DropdownMenuItem(value: category, child: Text(category));
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddCategory()),
                          ).then((newCategory) {
                            if (newCategory != null) {
                              setState(() {
                                categories.add(newCategory);
                                _selectedCategory = newCategory;
                              });
                            }
                          });
                        },
                        child: Icon(Icons.add_circle_outline_rounded, size: 30, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField("Sale Price", _salePriceController)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Purchase Price", _purchasePriceController)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField("Tax in %", _taxPercentController)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Tax in Price", _taxPriceController)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildTextField("Net Price", _netPriceController)),
                    const SizedBox(width: 10),
                    Expanded(child: buildTextField("Minimum Quantity", _minQuantityController)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
      ),
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final List<File> images;
  final int currentIndex;
  final PageController pageController;
  final Function(int) removeImage;

  const ImagePickerWidget({
    required this.screenHeight,
    required this.screenWidth,
    required this.images,
    required this.currentIndex,
    required this.pageController,
    required this.removeImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: screenHeight * 0.3,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: images.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: screenWidth * 0.1, color: Colors.grey[600]),
                const SizedBox(height: 10),
                Text("Tap to add images (1-8)", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          )
              : PageView.builder(
            controller: pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.file(images[index], fit: BoxFit.cover, width: double.infinity);
            },
          ),
        ),
        if (images.isNotEmpty)
          Positioned(
            top: screenHeight * 0.01,
            right: screenWidth * 0.02,
            child: GestureDetector(
              onTap: () => removeImage(currentIndex),
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.01),
                decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                child: Icon(Icons.close, color: AppColors.primaryColor, size: screenWidth * 0.05),
              ),
            ),
          ),
      ],
    );
  }
}

*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'addItem_provider.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Save Item Details",
        backgroundColor: Colors.blue,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            provider.uploadItem(context);
          }
        },
        child: const Icon(Icons.save, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: provider.pickImages,
                child: ImagePickerWidget(images: provider.images, removeImage: provider.removeImage),
              ),
              const SizedBox(height: 16),
              buildTextField("Item Name", provider.itemNameController),
              buildTextField("Description", provider.descriptionController, lines: 2),
              buildTextField("Sale Price", provider.salePriceController),
              buildTextField("Purchase Price", provider.purchasePriceController),
              buildTextField("Tax in %", provider.taxPercentController),
              buildTextField("Tax Amount", provider.taxPriceController),
              buildTextField("Net Price", provider.netPriceController),
              buildTextField("Minimum Quantity", provider.minQuantityController),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final List<File> images;
  final Function(int) removeImage;

  const ImagePickerWidget({required this.images, required this.removeImage, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: images.isEmpty
          ? const Center(child: Text("Tap to add images (1-8)"))
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(images[index], width: 100, height: 100, fit: BoxFit.cover),
              ),
              GestureDetector(
                onTap: () => removeImage(index),
                child: const Icon(Icons.remove_circle, color: Colors.red),
              ),
            ],
          );
        },
      ),
    );
  }
}
