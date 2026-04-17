import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/invoice_controler.dart';
import '../Model/invoice_model.dart';

class InvoicePage extends StatelessWidget {
  final InvoiceController controller = Get.put(InvoiceController());

  final TextEditingController numberController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  final TextEditingController itemUnitPriceController = TextEditingController();

  final List<InvoiceItem> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invoice Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'Invoice Number'),
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: dueDateController,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Client Name'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Client Address'),
              ),
              SizedBox(height: 20),
              Text('Items:', style: TextStyle(fontSize: 20)),
              TextField(
                controller: itemDescriptionController,
                decoration: InputDecoration(labelText: 'Item Description'),
              ),
              TextField(
                controller: itemQuantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: itemUnitPriceController,
                decoration: InputDecoration(labelText: 'Unit Price'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () {
                  final description = itemDescriptionController.text;
                  final quantity = double.tryParse(itemQuantityController.text) ?? 0.0;
                  final unitPrice = double.tryParse(itemUnitPriceController.text) ?? 0.0;

                  if (description.isNotEmpty && quantity > 0 && unitPrice > 0) {
                    items.add(InvoiceItem(description: description, quantity: quantity, unitPrice: unitPrice));
                    itemDescriptionController.clear();
                    itemQuantityController.clear();
                    itemUnitPriceController.clear();
                  }
                },
                child: Text('Add Item'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final invoiceNumber = numberController.text;
                  final date = DateTime.parse(dateController.text);
                  final dueDate = DateTime.parse(dueDateController.text);
                  final clientName = nameController.text;
                  final clientAddress = addressController.text;

                  controller.setInvoice(invoiceNumber, date, dueDate, clientName, clientAddress, items);
                  controller.generatePdf();
                },
                child: Text('Generate Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}