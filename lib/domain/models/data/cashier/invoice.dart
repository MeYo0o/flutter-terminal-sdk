import 'package:flutter_terminal_sdk/domain/models/util/json_pick.dart';
import 'package:flutter_terminal_sdk/domain/models/intents_list_response.dart'
    show Pagination;

num? _optionalNum(Map<String, dynamic> json, List<String> keys) {
  final value = pickKey(json, keys);
  return value == null ? null : toNumSafe(value);
}

String? _optionalString(Map<String, dynamic> json, List<String> keys) {
  final value = pickKey(json, keys);
  return value == null ? null : toStringSafe(value);
}

class InvoiceItem {
  final String? id;
  final String name;
  final num unitPrice;
  final int quantity;
  final num totalPrice;
  final num vat;
  final num netTotal;

  const InvoiceItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.vat,
    required this.netTotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: _optionalString(json, ['id']),
      name: toStringSafe(pickKey(json, ['name'])),
      unitPrice: toNumSafe(pickKey(json, ['unit_price', 'unitPrice'])),
      quantity: toNumSafe(pickKey(json, ['quantity'])).toInt(),
      totalPrice: toNumSafe(pickKey(json, ['total_price', 'totalPrice'])),
      vat: toNumSafe(pickKey(json, ['vat'])),
      netTotal: toNumSafe(pickKey(json, ['net_total', 'netTotal'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit_price': unitPrice,
        'quantity': quantity,
        'total_price': totalPrice,
        'vat': vat,
        'net_total': netTotal,
      };
}

class InvoicePayment {
  final String? id;
  final num amount;
  final String paymentType;
  final String? createdAt;

  const InvoicePayment({
    required this.id,
    required this.amount,
    required this.paymentType,
    required this.createdAt,
  });

  factory InvoicePayment.fromJson(Map<String, dynamic> json) {
    return InvoicePayment(
      id: _optionalString(json, ['id']),
      amount: toNumSafe(pickKey(json, ['amount'])),
      paymentType: toStringSafe(pickKey(json, ['payment_type', 'paymentType'])),
      createdAt: _optionalString(json, ['created_at', 'createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'payment_type': paymentType,
        'created_at': createdAt,
      };
}

class InvoiceDetails {
  final String id;
  final String? merchantId;
  final String? terminalId;
  final num subTotal;
  final num vat;
  final num? vatAmount;
  final int? itemsCount;
  final num? total;
  final num netTotal;
  final List<InvoiceItem> items;
  final List<InvoicePayment> payments;

  const InvoiceDetails({
    required this.id,
    required this.merchantId,
    required this.terminalId,
    required this.subTotal,
    required this.vat,
    required this.vatAmount,
    required this.itemsCount,
    required this.total,
    required this.netTotal,
    required this.items,
    required this.payments,
  });

  factory InvoiceDetails.fromJson(Map<String, dynamic> json) {
    final itemsCountValue = pickKey(json, ['items_count', 'itemsCount']);
    return InvoiceDetails(
      id: toStringSafe(pickKey(json, ['id'])),
      merchantId:
          _optionalString(json, ['merchant_id', 'merchantID', 'merchantId']),
      terminalId:
          _optionalString(json, ['terminal_id', 'terminalID', 'terminalId']),
      subTotal: toNumSafe(pickKey(json, ['sub_total', 'subTotal'])),
      vat: toNumSafe(pickKey(json, ['vat'])),
      vatAmount: _optionalNum(json, ['vat_amount', 'vatAmount']),
      itemsCount:
          itemsCountValue == null ? null : toNumSafe(itemsCountValue).toInt(),
      total: _optionalNum(json, ['total']),
      netTotal: toNumSafe(pickKey(json, ['net_total', 'netTotal'])),
      items: _invoiceItems(pickKey(json, ['items'])),
      payments: _invoicePayments(pickKey(json, ['payments'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchant_id': merchantId,
        'terminal_id': terminalId,
        'sub_total': subTotal,
        'vat': vat,
        'vat_amount': vatAmount,
        'items_count': itemsCount,
        'total': total,
        'net_total': netTotal,
        'items': items.map((e) => e.toJson()).toList(),
        'payments': payments.map((e) => e.toJson()).toList(),
      };
}

class InvoiceResponse {
  final String id;
  final num subTotal;
  final num vat;
  final num? vatPercentage;
  final num netTotal;
  final num discount;
  final num discountPercentage;
  final num totalPaid;
  final num invoiceNumber;
  final String merchantName;
  final String merchantAddress;
  final String mcc;
  final String merchantPhoneNumber;
  final String tid;
  final List<InvoiceItem> items;
  final List<InvoicePayment> payments;
  final String createdAt;
  final String updatedAt;

  const InvoiceResponse({
    required this.id,
    required this.subTotal,
    required this.vat,
    required this.vatPercentage,
    required this.netTotal,
    required this.discount,
    required this.discountPercentage,
    required this.totalPaid,
    required this.invoiceNumber,
    required this.merchantName,
    required this.merchantAddress,
    required this.mcc,
    required this.merchantPhoneNumber,
    required this.tid,
    required this.items,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      id: toStringSafe(pickKey(json, ['id'])),
      subTotal: toNumSafe(pickKey(json, ['sub_total', 'subTotal'])),
      vat: toNumSafe(pickKey(json, ['vat'])),
      vatPercentage: _optionalNum(json, ['vat_percentage', 'vatPercentage']),
      netTotal: toNumSafe(pickKey(json, ['net_total', 'netTotal'])),
      discount: toNumSafe(pickKey(json, ['discount'])),
      discountPercentage: toNumSafe(
          pickKey(json, ['discount_percentage', 'discountPercentage'])),
      totalPaid: toNumSafe(pickKey(json, ['total_paid', 'totalPaid'])),
      invoiceNumber:
          toNumSafe(pickKey(json, ['invoice_number', 'invoiceNumber'])),
      merchantName:
          toStringSafe(pickKey(json, ['merchant_name', 'merchantName'])),
      merchantAddress:
          toStringSafe(pickKey(json, ['merchant_address', 'merchantAddress'])),
      mcc: toStringSafe(pickKey(json, ['mcc'])),
      merchantPhoneNumber: toStringSafe(
          pickKey(json, ['merchant_phone_number', 'merchantPhoneNumber'])),
      tid: toStringSafe(pickKey(json, ['tid'])),
      items: _invoiceItems(pickKey(json, ['items'])),
      payments: _invoicePayments(pickKey(json, ['payments'])),
      createdAt: toStringSafe(pickKey(json, ['created_at', 'createdAt'])),
      updatedAt: toStringSafe(pickKey(json, ['updated_at', 'updatedAt'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sub_total': subTotal,
        'vat': vat,
        'vat_percentage': vatPercentage,
        'net_total': netTotal,
        'discount': discount,
        'discount_percentage': discountPercentage,
        'total_paid': totalPaid,
        'invoice_number': invoiceNumber,
        'merchant_name': merchantName,
        'merchant_address': merchantAddress,
        'mcc': mcc,
        'merchant_phone_number': merchantPhoneNumber,
        'tid': tid,
        'items': items.map((e) => e.toJson()).toList(),
        'payments': payments.map((e) => e.toJson()).toList(),
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class InvoiceListResponse {
  final List<InvoiceDetails> data;
  final Pagination pagination;

  const InvoiceListResponse({
    required this.data,
    required this.pagination,
  });

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = pickKey(json, ['data', 'invoiceList', 'invoice_list']);
    final rawPagination = pickKey(json, ['pagination']);
    return InvoiceListResponse(
      data: rawList is List
          ? rawList
              .whereType<Map>()
              .map((e) => InvoiceDetails.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      pagination: rawPagination is Map
          ? Pagination.fromJson(Map<String, dynamic>.from(rawPagination))
          : Pagination(currentPage: 1, totalPages: 0, totalData: 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };
}

List<InvoiceItem> _invoiceItems(Object? raw) => raw is List
    ? raw
        .whereType<Map>()
        .map((e) => InvoiceItem.fromJson(Map<String, dynamic>.from(e)))
        .toList()
    : const [];

List<InvoicePayment> _invoicePayments(Object? raw) => raw is List
    ? raw
        .whereType<Map>()
        .map((e) => InvoicePayment.fromJson(Map<String, dynamic>.from(e)))
        .toList()
    : const [];
