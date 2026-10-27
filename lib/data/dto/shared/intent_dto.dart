/// Shared intent wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/intentDto`).
library;

import 'transaction_dto.dart';

class IntentCurrencyDto {
  final String? code;
  final Object? decimals;
  final String? name;
  final String? number;

  const IntentCurrencyDto({this.code, this.decimals, this.name, this.number});

  factory IntentCurrencyDto.fromMap(Map<String, dynamic> map) {
    return IntentCurrencyDto(
      code: map['code'] as String?,
      decimals: map['decimals'],
      name: map['name'] as String?,
      number: map['number'] as String?,
    );
  }
}

class IntentTransactionSchemeDto {
  final String? english;
  final String? arabic;
  final String? turkish;

  const IntentTransactionSchemeDto({this.english, this.arabic, this.turkish});

  factory IntentTransactionSchemeDto.fromMap(Map<String, dynamic> map) {
    return IntentTransactionSchemeDto(
      english: map['english'] as String?,
      arabic: map['arabic'] as String?,
      turkish: map['turkish'] as String?,
    );
  }
}

class IntentTransactionDto {
  final Object? uuid;
  final String? pan;
  final IntentTransactionSchemeDto? scheme;
  final Object? amountAuthorized;
  final IntentCurrencyDto? currency;
  final bool? isApproved;
  final bool? isReversed;
  final String? retrievalReferenceNumber;
  final String? customerReferenceNumber;

  const IntentTransactionDto({
    this.uuid,
    this.pan,
    this.scheme,
    this.amountAuthorized,
    this.currency,
    this.isApproved,
    this.isReversed,
    this.retrievalReferenceNumber,
    this.customerReferenceNumber,
  });

  factory IntentTransactionDto.fromMap(Map<String, dynamic> map) {
    return IntentTransactionDto(
      uuid: map['uuid'],
      pan: map['pan'] as String?,
      scheme: map['scheme'] == null
          ? null
          : IntentTransactionSchemeDto.fromMap(
              Map<String, dynamic>.from(map['scheme'] as Map)),
      amountAuthorized: map['amountAuthorized'],
      currency: map['currency'] == null
          ? null
          : IntentCurrencyDto.fromMap(
              Map<String, dynamic>.from(map['currency'] as Map)),
      isApproved: map['isApproved'] as bool?,
      isReversed: map['isReversed'] as bool?,
      retrievalReferenceNumber: map['retrievalReferenceNumber'] as String?,
      customerReferenceNumber: map['customerReferenceNumber'] as String?,
    );
  }
}

class IntentItemDto {
  final String? customerReferenceNumber;
  final String? terminalID;
  final Object? amount;
  final Object? id;
  final String? originalIntentID;
  final String? status;
  final String? type;
  final String? createdAt;
  final String? completedAt;
  final String? cancelledAt;
  final List<IntentTransactionDto>? transactions;

  const IntentItemDto({
    this.customerReferenceNumber,
    this.terminalID,
    this.amount,
    this.id,
    this.originalIntentID,
    this.status,
    this.type,
    this.createdAt,
    this.completedAt,
    this.cancelledAt,
    this.transactions,
  });

  factory IntentItemDto.fromMap(Map<String, dynamic> map) {
    return IntentItemDto(
      customerReferenceNumber: map['customerReferenceNumber'] as String?,
      terminalID: map['terminalID'] as String?,
      amount: map['amount'],
      id: map['id'],
      originalIntentID: map['originalIntentID'] as String?,
      status: map['status'] as String?,
      type: map['type'] as String?,
      createdAt: map['createdAt'] as String?,
      completedAt: map['completedAt'] as String?,
      cancelledAt: map['cancelledAt'] as String?,
      transactions: (map['transactions'] as List?)
          ?.map((e) =>
              IntentTransactionDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class IntentsListResponseDto {
  final List<IntentItemDto>? data;
  final PaginationDto? pagination;

  const IntentsListResponseDto({this.data, this.pagination});

  factory IntentsListResponseDto.fromMap(Map<String, dynamic> map) {
    return IntentsListResponseDto(
      data: (map['data'] as List?)
          ?.map(
              (e) => IntentItemDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagination: map['pagination'] == null
          ? null
          : PaginationDto.fromMap(
              Map<String, dynamic>.from(map['pagination'] as Map)),
    );
  }
}

class TransactionResponseTurkeyReceiptDto {
  final String? standard;
  final Object? id;
  final String? data;

  const TransactionResponseTurkeyReceiptDto(
      {this.standard, this.id, this.data});

  factory TransactionResponseTurkeyReceiptDto.fromMap(
      Map<String, dynamic> map) {
    return TransactionResponseTurkeyReceiptDto(
      standard: map['standard'] as String?,
      id: map['id'],
      data: map['data'] as String?,
    );
  }
}

class TransactionResponseTurkeyEventDto {
  final TransactionResponseTurkeyReceiptDto? receipt;
  final Object? rrn;
  final String? status;

  const TransactionResponseTurkeyEventDto(
      {this.receipt, this.rrn, this.status});

  factory TransactionResponseTurkeyEventDto.fromMap(Map<String, dynamic> map) {
    return TransactionResponseTurkeyEventDto(
      receipt: map['receipt'] == null
          ? null
          : TransactionResponseTurkeyReceiptDto.fromMap(
              Map<String, dynamic>.from(map['receipt'] as Map)),
      rrn: map['rrn'],
      status: map['status'] as String?,
    );
  }
}

class TransactionResponseTurkeyDto {
  final Object? id;
  final List<dynamic>? performance;
  final String? cancelReason;
  final String? status;
  final Object? currency;
  final String? createdAt;
  final String? completedAt;
  final String? referenceId;
  final String? orderId;
  final bool? pinRequired;
  final Map<String, dynamic>? card;
  final List<TransactionResponseTurkeyEventDto>? events;
  final Object? amountOther;

  const TransactionResponseTurkeyDto({
    this.id,
    this.performance,
    this.cancelReason,
    this.status,
    this.currency,
    this.createdAt,
    this.completedAt,
    this.referenceId,
    this.orderId,
    this.pinRequired,
    this.card,
    this.events,
    this.amountOther,
  });

  factory TransactionResponseTurkeyDto.fromMap(Map<String, dynamic> map) {
    return TransactionResponseTurkeyDto(
      id: map['id'],
      performance: map['performance'] as List?,
      cancelReason: map['cancelReason'] as String?,
      status: map['status'] as String?,
      currency: map['currency'],
      createdAt: map['createdAt'] as String?,
      completedAt: map['completedAt'] as String?,
      referenceId: map['referenceId'] as String?,
      orderId: map['orderId'] as String?,
      pinRequired: map['pinRequired'] as bool?,
      card: map['card'] == null
          ? null
          : Map<String, dynamic>.from(map['card'] as Map),
      events: (map['events'] as List?)
          ?.map((e) => TransactionResponseTurkeyEventDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      amountOther: map['amountOther'],
    );
  }
}

class IntentResponseTurkeyDetailsDto {
  final Object? intentId;
  final String? referenceId;
  final String? type;
  final String? status;
  final Object? amount;
  final bool? pinRequired;
  final String? createdAt;
  final String? completedAt;
  final String? receiptsUrl;
  final String? groupReceiptsUrl;
  final List<TransactionResponseTurkeyDto>? transactions;

  const IntentResponseTurkeyDetailsDto({
    this.intentId,
    this.referenceId,
    this.type,
    this.status,
    this.amount,
    this.pinRequired,
    this.createdAt,
    this.completedAt,
    this.receiptsUrl,
    this.groupReceiptsUrl,
    this.transactions,
  });

  factory IntentResponseTurkeyDetailsDto.fromMap(Map<String, dynamic> map) {
    return IntentResponseTurkeyDetailsDto(
      intentId: map['intentId'],
      referenceId: map['referenceId'] as String?,
      type: map['type'] as String?,
      status: map['status'] as String?,
      amount: map['amount'],
      pinRequired: map['pinRequired'] as bool?,
      createdAt: map['createdAt'] as String?,
      completedAt: map['completedAt'] as String?,
      receiptsUrl: map['receiptsUrl'] as String?,
      groupReceiptsUrl: map['groupReceiptsUrl'] as String?,
      transactions: (map['transactions'] as List?)
          ?.map((e) => TransactionResponseTurkeyDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class IntentResponseTurkeyDto {
  final String? status;
  final IntentResponseTurkeyDetailsDto? details;
  final List<TransactionResponseTurkeyDto>? transactions;

  const IntentResponseTurkeyDto({this.status, this.details, this.transactions});

  factory IntentResponseTurkeyDto.fromMap(Map<String, dynamic> map) {
    return IntentResponseTurkeyDto(
      status: map['status'] as String?,
      details: map['details'] == null
          ? null
          : IntentResponseTurkeyDetailsDto.fromMap(
              Map<String, dynamic>.from(map['details'] as Map)),
      transactions: (map['transactions'] as List?)
          ?.map((e) => TransactionResponseTurkeyDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
