// Request parameter types for the iOS-only cashier operations.
//
// Mirrors the React Native `CreateInvoiceParams` / `ShareReceiptParams` /
// `CreateProductParams` shapes. Payload key casing matches what the iOS
// Flutter bridge reads (camelCase preferred, snake_case also accepted).

enum InvoicePaymentType { cash, card }

enum CashierReceiptType { transaction, invoice }

enum CashierShareMethod { mobile, email }

class CreateInvoiceItemInput {
  final String name;
  final num unitPrice;
  final int quantity;
  final num? vat;

  const CreateInvoiceItemInput({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.vat,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
        if (vat != null) 'vat': vat,
      };
}

class CreateInvoiceParams {
  final List<CreateInvoiceItemInput> items;
  final num vatPercentage;
  final InvoicePaymentType type;
  final num? paidAmount;
  final num? discountPercentage;
  final num? discount;

  const CreateInvoiceParams({
    required this.items,
    required this.vatPercentage,
    required this.type,
    this.paidAmount,
    this.discountPercentage,
    this.discount,
  });

  Map<String, dynamic> toPayload() => {
        'items': items.map((e) => e.toJson()).toList(),
        'vatPercentage': vatPercentage,
        'type': type.name,
        if (paidAmount != null) 'paidAmount': paidAmount,
        if (discountPercentage != null)
          'discountPercentage': discountPercentage,
        if (discount != null) 'discount': discount,
      };
}

class CreateProductParams {
  final String name;
  final String description;
  final num price;
  final bool isVATExcluded;

  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    this.isVATExcluded = false,
  });

  Map<String, dynamic> toPayload() => {
        'name': name,
        'description': description,
        'price': price,
        'isVATExcluded': isVATExcluded,
      };
}

class ShareReceiptParams {
  final CashierReceiptType receiptType;
  final String receiptId;
  final CashierShareMethod method;
  final String value;

  const ShareReceiptParams({
    required this.receiptType,
    required this.receiptId,
    required this.method,
    required this.value,
  });

  Map<String, dynamic> toPayload() => {
        'receiptType': receiptType.name,
        'receiptId': receiptId,
        'method': method.name,
        'value': value,
      };
}

class ShareInvoiceParams {
  final Map<String, dynamic> fields;

  const ShareInvoiceParams(this.fields);

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(fields);
}
