/// Shared cashier wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/cashierDto`).
library;

import 'transaction_dto.dart';

class InvoiceItemDto {
  final Object? id;
  final String? name;
  final Object? unitPrice;
  final Object? quantity;
  final Object? totalPrice;
  final Object? vat;
  final Object? netTotal;

  const InvoiceItemDto({
    this.id,
    this.name,
    this.unitPrice,
    this.quantity,
    this.totalPrice,
    this.vat,
    this.netTotal,
  });

  factory InvoiceItemDto.fromMap(Map<String, dynamic> map) {
    return InvoiceItemDto(
      id: map['id'],
      name: map['name'] as String?,
      unitPrice: map['unitPrice'],
      quantity: map['quantity'],
      totalPrice: map['totalPrice'],
      vat: map['vat'],
      netTotal: map['netTotal'],
    );
  }
}

class InvoicePaymentDto {
  final Object? id;
  final Object? amount;
  final String? paymentType;
  final String? createdAt;

  const InvoicePaymentDto(
      {this.id, this.amount, this.paymentType, this.createdAt});

  factory InvoicePaymentDto.fromMap(Map<String, dynamic> map) {
    return InvoicePaymentDto(
      id: map['id'],
      amount: map['amount'],
      paymentType: map['paymentType'] as String?,
      createdAt: map['createdAt'] as String?,
    );
  }
}

class InvoiceDetailsDto {
  final Object? id;
  final Object? merchantID;
  final Object? merchantId;
  final Object? terminalID;
  final Object? terminalId;
  final Object? subTotal;
  final Object? vat;
  final Object? vatAmount;
  final Object? itemsCount;
  final Object? total;
  final Object? netTotal;
  final List<InvoiceItemDto>? items;
  final List<InvoicePaymentDto>? payments;

  const InvoiceDetailsDto({
    this.id,
    this.merchantID,
    this.merchantId,
    this.terminalID,
    this.terminalId,
    this.subTotal,
    this.vat,
    this.vatAmount,
    this.itemsCount,
    this.total,
    this.netTotal,
    this.items,
    this.payments,
  });

  factory InvoiceDetailsDto.fromMap(Map<String, dynamic> map) {
    return InvoiceDetailsDto(
      id: map['id'],
      merchantID: map['merchantID'],
      merchantId: map['merchantId'],
      terminalID: map['terminalID'],
      terminalId: map['terminalId'],
      subTotal: map['subTotal'],
      vat: map['vat'],
      vatAmount: map['vatAmount'],
      itemsCount: map['itemsCount'],
      total: map['total'],
      netTotal: map['netTotal'],
      items: (map['items'] as List?)
          ?.map((e) =>
              InvoiceItemDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      payments: (map['payments'] as List?)
          ?.map((e) =>
              InvoicePaymentDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class InvoiceResponseDto {
  final Object? id;
  final Object? subTotal;
  final Object? vat;
  final Object? vatPercentage;
  final Object? netTotal;
  final Object? discount;
  final Object? discountPercentage;
  final Object? totalPaid;
  final Object? invoiceNumber;
  final String? merchantName;
  final String? merchantAddress;
  final String? mcc;
  final String? merchantPhoneNumber;
  final String? tid;
  final List<InvoiceItemDto>? items;
  final List<InvoicePaymentDto>? payments;
  final String? createdAt;
  final String? updatedAt;

  const InvoiceResponseDto({
    this.id,
    this.subTotal,
    this.vat,
    this.vatPercentage,
    this.netTotal,
    this.discount,
    this.discountPercentage,
    this.totalPaid,
    this.invoiceNumber,
    this.merchantName,
    this.merchantAddress,
    this.mcc,
    this.merchantPhoneNumber,
    this.tid,
    this.items,
    this.payments,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceResponseDto.fromMap(Map<String, dynamic> map) {
    return InvoiceResponseDto(
      id: map['id'],
      subTotal: map['subTotal'],
      vat: map['vat'],
      vatPercentage: map['vatPercentage'],
      netTotal: map['netTotal'],
      discount: map['discount'],
      discountPercentage: map['discountPercentage'],
      totalPaid: map['totalPaid'],
      invoiceNumber: map['invoiceNumber'],
      merchantName: map['merchantName'] as String?,
      merchantAddress: map['merchantAddress'] as String?,
      mcc: map['mcc'] as String?,
      merchantPhoneNumber: map['merchantPhoneNumber'] as String?,
      tid: map['tid'] as String?,
      items: (map['items'] as List?)
          ?.map((e) =>
              InvoiceItemDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      payments: (map['payments'] as List?)
          ?.map((e) =>
              InvoicePaymentDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }
}

class InvoiceListResponseDto {
  final List<InvoiceDetailsDto>? data;
  final List<InvoiceDetailsDto>? invoiceList;
  final PaginationDto? pagination;

  const InvoiceListResponseDto({this.data, this.invoiceList, this.pagination});

  factory InvoiceListResponseDto.fromMap(Map<String, dynamic> map) {
    return InvoiceListResponseDto(
      data: (map['data'] as List?)
          ?.map((e) =>
              InvoiceDetailsDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      invoiceList: (map['invoiceList'] as List?)
          ?.map((e) =>
              InvoiceDetailsDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagination: map['pagination'] == null
          ? null
          : PaginationDto.fromMap(
              Map<String, dynamic>.from(map['pagination'] as Map)),
    );
  }
}

class ProductDto {
  final Object? id;
  final Object? productId;
  final Object? uuid;
  final String? name;
  final String? description;
  final Object? price;
  final String? type;
  final String? imageLink;
  final bool? isVATExcluded;
  final bool? vatExcluded;

  const ProductDto({
    this.id,
    this.productId,
    this.uuid,
    this.name,
    this.description,
    this.price,
    this.type,
    this.imageLink,
    this.isVATExcluded,
    this.vatExcluded,
  });

  factory ProductDto.fromMap(Map<String, dynamic> map) {
    return ProductDto(
      id: map['id'],
      productId: map['productId'],
      uuid: map['uuid'],
      name: map['name'] as String?,
      description: map['description'] as String?,
      price: map['price'],
      type: map['type'] as String?,
      imageLink: map['imageLink'] as String?,
      isVATExcluded: map['isVATExcluded'] as bool?,
      vatExcluded: map['vatExcluded'] as bool?,
    );
  }
}

class ProductsListResponseDto {
  final List<ProductDto>? data;
  final List<ProductDto>? products;
  final PaginationDto? pagination;

  const ProductsListResponseDto({this.data, this.products, this.pagination});

  factory ProductsListResponseDto.fromMap(Map<String, dynamic> map) {
    return ProductsListResponseDto(
      data: (map['data'] as List?)
          ?.map((e) => ProductDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      products: (map['products'] as List?)
          ?.map((e) => ProductDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagination: map['pagination'] == null
          ? null
          : PaginationDto.fromMap(
              Map<String, dynamic>.from(map['pagination'] as Map)),
    );
  }
}
