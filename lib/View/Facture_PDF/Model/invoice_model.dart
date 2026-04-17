class Invoice {
  final String invoiceNumber;
  final DateTime date;
  final DateTime dueDate;
  final String clientName;
  final String clientAddress;
  final List<InvoiceItem> items;
  final double taxRate;

  Invoice({
    required this.invoiceNumber,
    required this.date,
    required this.dueDate,
    required this.clientName,
    required this.clientAddress,
    required this.items,
    this.taxRate = 0.2, // 20% par défaut
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;
}

class InvoiceItem {
  final String description;
  final double quantity;
  final double unitPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}