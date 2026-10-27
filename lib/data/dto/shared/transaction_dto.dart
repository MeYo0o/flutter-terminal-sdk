/// Shared transaction wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/transactionDto`).
library;

class TransactionListCurrencyDto {
  final String? english;
  final String? arabic;
  final String? turkish;
  final String? symbol;

  const TransactionListCurrencyDto({
    this.english,
    this.arabic,
    this.turkish,
    this.symbol,
  });

  factory TransactionListCurrencyDto.fromMap(Map<String, dynamic> map) {
    return TransactionListCurrencyDto(
      english: map['english'] as String?,
      arabic: map['arabic'] as String?,
      turkish: map['turkish'] as String?,
      symbol: map['symbol'] as String?,
    );
  }
}

class TransactionListPerformanceDto {
  final String? type;
  final Object? timeStamp;

  const TransactionListPerformanceDto({this.type, this.timeStamp});

  factory TransactionListPerformanceDto.fromMap(Map<String, dynamic> map) {
    return TransactionListPerformanceDto(
      type: map['type'] as String?,
      timeStamp: map['timeStamp'],
    );
  }
}

class TransactionListItemDto {
  final Object? uuid;
  final String? scheme;
  final String? customerReferenceNumber;
  final String? pan;
  final Object? amountAuthorized;
  final String? transactionType;
  final TransactionListCurrencyDto? currency;
  final bool? isApproved;
  final bool? isReversed;
  final bool? isReconciled;
  final String? startDate;
  final String? startTime;
  final List<TransactionListPerformanceDto>? performance;

  const TransactionListItemDto({
    this.uuid,
    this.scheme,
    this.customerReferenceNumber,
    this.pan,
    this.amountAuthorized,
    this.transactionType,
    this.currency,
    this.isApproved,
    this.isReversed,
    this.isReconciled,
    this.startDate,
    this.startTime,
    this.performance,
  });

  factory TransactionListItemDto.fromMap(Map<String, dynamic> map) {
    return TransactionListItemDto(
      uuid: map['uuid'],
      scheme: map['scheme'] as String?,
      customerReferenceNumber: map['customerReferenceNumber'] as String?,
      pan: map['pan'] as String?,
      amountAuthorized: map['amountAuthorized'],
      transactionType: map['transactionType'] as String?,
      currency: map['currency'] == null
          ? null
          : TransactionListCurrencyDto.fromMap(
              Map<String, dynamic>.from(map['currency'] as Map)),
      isApproved: map['isApproved'] as bool?,
      isReversed: map['isReversed'] as bool?,
      isReconciled: map['isReconciled'] as bool?,
      startDate: map['startDate'] as String?,
      startTime: map['startTime'] as String?,
      performance: (map['performance'] as List?)
          ?.map((e) => TransactionListPerformanceDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class PaginationDto {
  final Object? currentPage;
  final Object? totalPages;
  final Object? totalData;

  const PaginationDto({this.currentPage, this.totalPages, this.totalData});

  factory PaginationDto.fromMap(Map<String, dynamic> map) {
    return PaginationDto(
      currentPage: map['currentPage'],
      totalPages: map['totalPages'],
      totalData: map['totalData'],
    );
  }
}

class TransactionsResponseDto {
  final List<TransactionListItemDto>? data;
  final PaginationDto? pagination;

  const TransactionsResponseDto({this.data, this.pagination});

  factory TransactionsResponseDto.fromMap(Map<String, dynamic> map) {
    return TransactionsResponseDto(
      data: (map['data'] as List?)
          ?.map((e) => TransactionListItemDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagination: map['pagination'] == null
          ? null
          : PaginationDto.fromMap(
              Map<String, dynamic>.from(map['pagination'] as Map)),
    );
  }
}

class TransactionReceiptDto {
  final String? standard;
  final String? type;
  final Object? id;
  final Object? data;

  const TransactionReceiptDto({this.standard, this.type, this.id, this.data});

  factory TransactionReceiptDto.fromMap(Map<String, dynamic> map) {
    return TransactionReceiptDto(
      standard: map['standard'] as String?,
      type: map['type'] as String?,
      id: map['id'],
      data: map['data'],
    );
  }
}

class TransactionEventDto {
  final Object? rrn;
  final String? status;
  final Object? stan;
  final String? type;
  final TransactionReceiptDto? receipt;

  const TransactionEventDto({
    this.rrn,
    this.status,
    this.stan,
    this.type,
    this.receipt,
  });

  factory TransactionEventDto.fromMap(Map<String, dynamic> map) {
    return TransactionEventDto(
      rrn: map['rrn'],
      status: map['status'] as String?,
      stan: map['stan'],
      type: map['type'] as String?,
      receipt: map['receipt'] == null
          ? null
          : TransactionReceiptDto.fromMap(
              Map<String, dynamic>.from(map['receipt'] as Map)),
    );
  }
}

class TransactionCardDto {
  final String? pan;
  final String? exp;
  final String? brandCode;
  final String? panSuffix;

  const TransactionCardDto(
      {this.pan, this.exp, this.brandCode, this.panSuffix});

  factory TransactionCardDto.fromMap(Map<String, dynamic> map) {
    return TransactionCardDto(
      pan: map['pan'] as String?,
      exp: map['exp'] as String?,
      brandCode: map['brandCode'] as String?,
      panSuffix: map['panSuffix'] as String?,
    );
  }
}

class TransactionResponseDto {
  final Object? id;
  final String? status;
  final String? createdAt;
  final Object? amount;
  final String? currency;
  final String? completedAt;
  final String? canceledAt;
  final String? cancelReason;
  final String? referenceId;
  final String? orderId;
  final bool? pinRequired;
  final TransactionCardDto? card;
  final List<TransactionEventDto>? events;
  final Object? amountOther;
  final List<dynamic>? performance;

  const TransactionResponseDto({
    this.id,
    this.status,
    this.createdAt,
    this.amount,
    this.currency,
    this.completedAt,
    this.canceledAt,
    this.cancelReason,
    this.referenceId,
    this.orderId,
    this.pinRequired,
    this.card,
    this.events,
    this.amountOther,
    this.performance,
  });

  factory TransactionResponseDto.fromMap(Map<String, dynamic> map) {
    return TransactionResponseDto(
      id: map['id'],
      status: map['status'] as String?,
      createdAt: map['createdAt'] as String?,
      amount: map['amount'],
      currency: map['currency'] as String?,
      completedAt: map['completedAt'] as String?,
      canceledAt: map['canceledAt'] as String?,
      cancelReason: map['cancelReason'] as String?,
      referenceId: map['referenceId'] as String?,
      orderId: map['orderId'] as String?,
      pinRequired: map['pinRequired'] as bool?,
      card: map['card'] == null
          ? null
          : TransactionCardDto.fromMap(
              Map<String, dynamic>.from(map['card'] as Map)),
      events: (map['events'] as List?)
          ?.map((e) =>
              TransactionEventDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      amountOther: map['amountOther'],
      performance: map['performance'] as List?,
    );
  }
}

class IntentDetailsDto {
  final Object? amount;
  final String? completedAt;
  final String? createdAt;
  final Object? intentId;
  final bool? pinRequired;
  final String? receiptsUrl;
  final String? groupReceiptsUrl;
  final String? referenceId;
  final String? status;
  final String? type;
  final List<TransactionResponseDto>? transactions;

  const IntentDetailsDto({
    this.amount,
    this.completedAt,
    this.createdAt,
    this.intentId,
    this.pinRequired,
    this.receiptsUrl,
    this.groupReceiptsUrl,
    this.referenceId,
    this.status,
    this.type,
    this.transactions,
  });

  factory IntentDetailsDto.fromMap(Map<String, dynamic> map) {
    return IntentDetailsDto(
      amount: map['amount'],
      completedAt: map['completedAt'] as String?,
      createdAt: map['createdAt'] as String?,
      intentId: map['intentId'],
      pinRequired: map['pinRequired'] as bool?,
      receiptsUrl: map['receiptsUrl'] as String?,
      groupReceiptsUrl: map['groupReceiptsUrl'] as String?,
      referenceId: map['referenceId'] as String?,
      status: map['status'] as String?,
      type: map['type'] as String?,
      transactions: (map['transactions'] as List?)
          ?.map((e) => TransactionResponseDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class PurchaseOrRefundResponseDto {
  final String? status;
  final IntentDetailsDto? details;

  const PurchaseOrRefundResponseDto({this.status, this.details});

  factory PurchaseOrRefundResponseDto.fromMap(Map<String, dynamic> map) {
    return PurchaseOrRefundResponseDto(
      status: map['status'] as String?,
      details: map['details'] == null
          ? null
          : IntentDetailsDto.fromMap(
              Map<String, dynamic>.from(map['details'] as Map)),
    );
  }
}

typedef ReverseResponseDto = IntentDetailsDto;

class AuthorizeResponseDto {
  final String? status;
  final IntentDetailsDto? details;

  const AuthorizeResponseDto({this.status, this.details});

  factory AuthorizeResponseDto.fromMap(Map<String, dynamic> map) {
    return AuthorizeResponseDto(
      status: map['status'] as String?,
      details: map['details'] == null
          ? null
          : IntentDetailsDto.fromMap(
              Map<String, dynamic>.from(map['details'] as Map)),
    );
  }
}

class CaptureResponseDto {
  final String? status;
  final IntentDetailsDto? details;
  final List<TransactionEventDto>? events;

  const CaptureResponseDto({this.status, this.details, this.events});

  factory CaptureResponseDto.fromMap(Map<String, dynamic> map) {
    return CaptureResponseDto(
      status: map['status'] as String?,
      details: map['details'] == null
          ? null
          : IntentDetailsDto.fromMap(
              Map<String, dynamic>.from(map['details'] as Map)),
      events: (map['events'] as List?)
          ?.map((e) =>
              TransactionEventDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class VoidAuthorizationResponseDto {
  final String? status;
  final IntentDetailsDto? details;

  const VoidAuthorizationResponseDto({this.status, this.details});

  factory VoidAuthorizationResponseDto.fromMap(Map<String, dynamic> map) {
    return VoidAuthorizationResponseDto(
      status: map['status'] as String?,
      details: map['details'] == null
          ? null
          : IntentDetailsDto.fromMap(
              Map<String, dynamic>.from(map['details'] as Map)),
    );
  }
}
