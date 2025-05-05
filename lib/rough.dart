// // Add this variable in the _InvoicePageState
// Map<String, dynamic>? _currentInvoice;
//
// @override
// void initState() {
//   super.initState();
//   _currentInvoice = widget.invoice;
//   _fetchItems();
//   _fetchRemainingBalance();
//
//   if (_currentInvoice != null) {
//     _invoiceId = _currentInvoice!['invoiceNumber'];
//     _referenceController.text = _currentInvoice!['referenceNumber'] ?? '';
//   }
//   // Rest of initState...
// }
//
// // Modify the save/update button's onPressed handler
// onPressed: _isButtonPressed
// ? null
// : () async {
// setState(() => _isButtonPressed = true);
// try {
// // ... (validation logic remains the same)
//
// // After saving/updating the invoice
// setState(() {
// _currentInvoice = {
// 'invoiceNumber': invoiceNumber,
// 'customerId': _selectedCustomerId,
// 'customerName': _selectedCustomerName ?? 'Unknown Customer',
// 'subtotal': subtotal,
// 'discount': _discount,
// 'grandTotal': grandTotal,
// 'paymentType': _paymentType,
// 'paymentMethod': _instantPaymentMethod,
// 'referenceNumber': _referenceController.text,
// 'createdAt': _dateController.text.isNotEmpty
// ? DateTime(
// DateTime.parse(_dateController.text).year,
// DateTime.parse(_dateController.text).month,
// DateTime.parse(_dateController.text).day,
// DateTime.now().hour,
// DateTime.now().minute,
// DateTime.now().second,
// ).toIso8601String()
//     : DateTime.now().toIso8601String(),
// 'items': _invoiceRows.map((row) {
// return {
// 'itemName': row['itemName'],
// 'rate': row['rate'],
// 'weight': row['weight'],
// 'qty': row['qty'],
// 'description': row['description'],
// 'total': row['total'],
// };
// }).toList(),
// };
// _invoiceId = invoiceNumber;
// });
//
// ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(
// content: Text(
// languageProvider.isEnglish
// ? 'Invoice saved successfully'
//     : 'انوائس کامیابی سے محفوظ ہوگئی',
// ),
// ),
// );
// } catch (e) {
// // ... (error handling remains the same)
// } finally {
// setState(() => _isButtonPressed = false);
// }
// },
//
// // Update the payment buttons to use _currentInvoice
// if (_currentInvoice != null)
// Row(
// children: [
// IconButton(
// icon: const Icon(Icons.payment),
// onPressed: () => onPaymentPressed(_currentInvoice!),
// ),
// IconButton(
// icon: const Icon(Icons.history),
// onPressed: () => onViewPayments(_currentInvoice!),
// ),
// ],
// ),