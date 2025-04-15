import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '5_Admin/AdminHomePages/Item_Managment/addItem_provider.dart';

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
