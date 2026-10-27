/// Shared reconciliation wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/reconciliationDto`).
library;

import 'transaction_dto.dart';

class LanguageContentDto {
  final String? english;
  final String? arabic;
  final String? turkish;
  final String? turkey;

  const LanguageContentDto(
      {this.english, this.arabic, this.turkish, this.turkey});

  factory LanguageContentDto.fromMap(Map<String, dynamic> map) {
    return LanguageContentDto(
      english: map['english'] as String?,
      arabic: map['arabic'] as String?,
      turkish: map['turkish'] as String?,
      turkey: map['turkey'] as String?,
    );
  }
}

class AddressContentDto {
  final String? english;
  final String? arabic;
  final String? turkish;
  final String? turkey;

  const AddressContentDto(
      {this.english, this.arabic, this.turkish, this.turkey});

  factory AddressContentDto.fromMap(Map<String, dynamic> map) {
    return AddressContentDto(
      english: map['english'] as String?,
      arabic: map['arabic'] as String?,
      turkish: map['turkish'] as String?,
      turkey: map['turkey'] as String?,
    );
  }
}

class MerchantDto {
  final Object? id;
  final LanguageContentDto? name;
  final AddressContentDto? address;
  final Object? categoryCode;
  final String? createdAt;

  const MerchantDto({
    this.id,
    this.name,
    this.address,
    this.categoryCode,
    this.createdAt,
  });

  factory MerchantDto.fromMap(Map<String, dynamic> map) {
    return MerchantDto(
      id: map['id'],
      name: map['name'] == null
          ? null
          : LanguageContentDto.fromMap(
              Map<String, dynamic>.from(map['name'] as Map)),
      address: map['address'] == null
          ? null
          : AddressContentDto.fromMap(
              Map<String, dynamic>.from(map['address'] as Map)),
      categoryCode: map['categoryCode'],
      createdAt: map['createdAt'] as String?,
    );
  }
}

class LabelValueDto {
  final LanguageContentDto? label;
  final Object? value;

  const LabelValueDto({this.label, this.value});

  factory LabelValueDto.fromMap(Map<String, dynamic> map) {
    return LabelValueDto(
      label: map['label'] == null
          ? null
          : LanguageContentDto.fromMap(
              Map<String, dynamic>.from(map['label'] as Map)),
      value: map['value'],
    );
  }
}

class DetailItemDto {
  final LanguageContentDto? label;
  final Object? total;
  final Object? count;

  const DetailItemDto({this.label, this.total, this.count});

  factory DetailItemDto.fromMap(Map<String, dynamic> map) {
    return DetailItemDto(
      label: map['label'] == null
          ? null
          : LanguageContentDto.fromMap(
              Map<String, dynamic>.from(map['label'] as Map)),
      total: map['total'],
      count: map['count'],
    );
  }
}

class ReconciliationDetailsDto {
  final DetailItemDto? total;
  final DetailItemDto? purchase;
  final DetailItemDto? purchaseReversal;
  final DetailItemDto? refund;
  final DetailItemDto? refundReversal;

  const ReconciliationDetailsDto({
    this.total,
    this.purchase,
    this.purchaseReversal,
    this.refund,
    this.refundReversal,
  });

  static DetailItemDto? _item(Object? raw) => raw == null
      ? null
      : DetailItemDto.fromMap(Map<String, dynamic>.from(raw as Map));

  factory ReconciliationDetailsDto.fromMap(Map<String, dynamic> map) {
    return ReconciliationDetailsDto(
      total: _item(map['total']),
      purchase: _item(map['purchase']),
      purchaseReversal: _item(map['purchaseReversal']),
      refund: _item(map['refund']),
      refundReversal: _item(map['refundReversal']),
    );
  }
}

class ReconciliationResponseDto {
  final Object? id;
  final String? date;
  final String? time;
  final String? startDate;
  final String? startTime;
  final String? endDate;
  final String? endTime;
  final MerchantDto? merchant;
  final ReconciliationDetailsDto? details;
  final LanguageContentDto? currency;
  final Map<String, dynamic>? data;

  const ReconciliationResponseDto({
    this.id,
    this.date,
    this.time,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.merchant,
    this.details,
    this.currency,
    this.data,
  });

  factory ReconciliationResponseDto.fromMap(Map<String, dynamic> map) {
    return ReconciliationResponseDto(
      id: map['id'],
      date: map['date'] as String?,
      time: map['time'] as String?,
      startDate: map['startDate'] as String?,
      startTime: map['startTime'] as String?,
      endDate: map['endDate'] as String?,
      endTime: map['endTime'] as String?,
      merchant: map['merchant'] == null
          ? null
          : MerchantDto.fromMap(
              Map<String, dynamic>.from(map['merchant'] as Map)),
      details: map['details'] == null
          ? null
          : ReconciliationDetailsDto.fromMap(
              Map<String, dynamic>.from(map['details'] as Map)),
      currency: map['currency'] == null
          ? null
          : LanguageContentDto.fromMap(
              Map<String, dynamic>.from(map['currency'] as Map)),
      data: map['data'] == null
          ? null
          : Map<String, dynamic>.from(map['data'] as Map),
    );
  }
}

class ReconciliationItemDto {
  final Object? id;
  final String? date;
  final String? time;
  final String? startDate;
  final String? startTime;
  final LabelValueDto? isBalanced;
  final Object? total;
  final LanguageContentDto? currency;

  const ReconciliationItemDto({
    this.id,
    this.date,
    this.time,
    this.startDate,
    this.startTime,
    this.isBalanced,
    this.total,
    this.currency,
  });

  factory ReconciliationItemDto.fromMap(Map<String, dynamic> map) {
    return ReconciliationItemDto(
      id: map['id'],
      date: map['date'] as String?,
      time: map['time'] as String?,
      startDate: map['startDate'] as String?,
      startTime: map['startTime'] as String?,
      isBalanced: map['isBalanced'] == null
          ? null
          : LabelValueDto.fromMap(
              Map<String, dynamic>.from(map['isBalanced'] as Map)),
      total: map['total'],
      currency: map['currency'] == null
          ? null
          : LanguageContentDto.fromMap(
              Map<String, dynamic>.from(map['currency'] as Map)),
    );
  }
}

class ReconciliationListResponseDto {
  final List<ReconciliationItemDto>? data;
  final List<ReconciliationItemDto>? reconciliationList;
  final PaginationDto? pagination;

  const ReconciliationListResponseDto({
    this.data,
    this.reconciliationList,
    this.pagination,
  });

  factory ReconciliationListResponseDto.fromMap(Map<String, dynamic> map) {
    return ReconciliationListResponseDto(
      data: (map['data'] as List?)
          ?.map((e) => ReconciliationItemDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      reconciliationList: (map['reconciliationList'] as List?)
          ?.map((e) => ReconciliationItemDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagination: map['pagination'] == null
          ? null
          : PaginationDto.fromMap(
              Map<String, dynamic>.from(map['pagination'] as Map)),
    );
  }
}

class ReconciliationReceiptReconciliationDto {
  final Object? id;

  const ReconciliationReceiptReconciliationDto({this.id});

  factory ReconciliationReceiptReconciliationDto.fromMap(
      Map<String, dynamic> map) {
    return ReconciliationReceiptReconciliationDto(id: map['id']);
  }
}

class ReconciliationReceiptDto {
  final Object? id;
  final String? standard;
  final String? operationType;
  final Object? data;
  final ReconciliationReceiptReconciliationDto? reconciliation;
  final Object? reconciliationId;
  final String? createdAt;
  final String? updatedAt;

  const ReconciliationReceiptDto({
    this.id,
    this.standard,
    this.operationType,
    this.data,
    this.reconciliation,
    this.reconciliationId,
    this.createdAt,
    this.updatedAt,
  });

  factory ReconciliationReceiptDto.fromMap(Map<String, dynamic> map) {
    return ReconciliationReceiptDto(
      id: map['id'],
      standard: map['standard'] as String?,
      operationType: map['operationType'] as String?,
      data: map['data'],
      reconciliation: map['reconciliation'] == null
          ? null
          : ReconciliationReceiptReconciliationDto.fromMap(
              Map<String, dynamic>.from(map['reconciliation'] as Map)),
      reconciliationId: map['reconciliationId'],
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }
}

class ReconciliationReceiptsResponseDto {
  final ReconciliationReceiptDto? receipt;
  final Object? reconciliationId;
  final Map<String, dynamic>? data;

  const ReconciliationReceiptsResponseDto({
    this.receipt,
    this.reconciliationId,
    this.data,
  });

  factory ReconciliationReceiptsResponseDto.fromMap(Map<String, dynamic> map) {
    return ReconciliationReceiptsResponseDto(
      receipt: map['receipt'] == null
          ? null
          : ReconciliationReceiptDto.fromMap(
              Map<String, dynamic>.from(map['receipt'] as Map)),
      reconciliationId: map['reconciliationId'],
      data: map['data'] == null
          ? null
          : Map<String, dynamic>.from(map['data'] as Map),
    );
  }
}
