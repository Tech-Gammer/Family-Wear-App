import 'package:family_wear_app/5_Admin/AdminHomePages/Item_Managment/purchase_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseItemPage extends StatefulWidget {
  const PurchaseItemPage({super.key});

  @override
  State<PurchaseItemPage> createState() => _PurchaseItemPageState();
}

class _PurchaseItemPageState extends State<PurchaseItemPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseProvider>(context, listen: false).fetchItems();
    });
  }

  Future<void> _selectDate(BuildContext context, PurchaseProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      provider.setPurchaseDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PurchaseProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Item', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader('Item Information'),
              const SizedBox(height: 16),
              _buildItemDropdown(provider, theme),
              const SizedBox(height: 20),
              _buildSectionHeader('Purchase Details'),
              const SizedBox(height: 16),
              _buildPriceField(provider,theme),
              const SizedBox(height: 16),
              _buildQuantityField(provider,theme),
              const SizedBox(height: 16),
              _buildSupplierField(provider,theme),
              const SizedBox(height: 16),
              _buildInvoiceField(provider,theme),
              const SizedBox(height: 16),
              _buildDatePicker(context, provider, theme),
              const SizedBox(height: 30),
              _buildSubmitButton(provider, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildItemDropdown(PurchaseProvider provider, ThemeData theme) {
    return DropdownButtonFormField<int>(
      value: provider.selectedItemId ?? (provider.items.isNotEmpty ? provider.items.first['item_id'] : null),
      decoration: InputDecoration(
        labelText: 'Select Item',
        prefixIcon: const Icon(Icons.shopping_cart, color: Colors.blueGrey),
        contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0), // Increased height
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
      items: provider.items.map((item) {
        return DropdownMenuItem<int>(
          value: item['item_id'],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['item_name'], style: const TextStyle(fontWeight: FontWeight.w500)),SizedBox(width: 20,),
              Text('Stock: ${item['minimum_qty']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => provider.setSelectedItem(value!),
      validator: (value) => value == null ? 'Select an item' : null,
      style: TextStyle(color: theme.primaryColor),
    );
  }


  Widget _buildPriceField(PurchaseProvider provider,ThemeData theme) {
    return TextFormField(
      controller: provider.purchasePriceController,
      decoration: InputDecoration(
        labelText: 'Purchase Price',
        prefixIcon: const Icon(Icons.attach_money, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
    );
  }

  Widget _buildQuantityField(PurchaseProvider provider,ThemeData theme) {
    return TextFormField(
      controller: provider.quantityController,
      decoration: InputDecoration(
        labelText: 'Quantity',
        prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
    );
  }

  Widget _buildSupplierField(PurchaseProvider provider,ThemeData theme) {
    return TextFormField(
      controller: provider.supplierController,
      decoration: InputDecoration(
        labelText: 'Supplier Name',
        prefixIcon: const Icon(Icons.person_outline, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
    );
  }

  Widget _buildInvoiceField(PurchaseProvider provider,ThemeData theme) {
    return TextFormField(
      controller: provider.invoiceController,
      decoration: InputDecoration(
        labelText: 'Invoice Number',
        prefixIcon: const Icon(Icons.description, color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, PurchaseProvider provider, ThemeData theme) {
    return InkWell(
      onTap: () => _selectDate(context, provider),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Purchase Date',
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.blueGrey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.primaryColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? 'Select date'
                  : DateFormat('MMM dd, yyyy').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null ? Colors.grey : theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(PurchaseProvider provider, ThemeData theme) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.save_alt, size: 24),
      label: const Text('SAVE PURCHASE', style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        shadowColor: theme.primaryColor.withOpacity(0.3),
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          if (_selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a purchase date')),
            );
            return;
          }

          final success = await provider.submitPurchase(_selectedDate!, context);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchase saved successfully'),
                backgroundColor: Colors.green,
              ),
            );

            setState(() => _selectedDate = null);
            await Future.delayed(const Duration(seconds: 1));
            Navigator.pop(context);
          }
        }
      },
    );
  }
}