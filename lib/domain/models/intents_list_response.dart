import 'util/json_pick.dart';

class IntentsListResponse {
  final List<Intent> data;
  final Pagination pagination;

  IntentsListResponse({
    required this.data,
    required this.pagination,
  });

  factory IntentsListResponse.fromJson(Map<String, dynamic> json) {
    return IntentsListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Intent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: Pagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
      };
}

class Intent {
  final String? customerReferenceNumber;
  final String? terminalId;
  final String? amount;
  final String id;
  final String? originalIntentId;
  final String? status;
  final String type;
  final String? createdAt;
  final String? completedAt;
  final String? cancelledAt;
  final List<IntentTransaction>? transactions;

  const Intent({
    this.terminalId,
    this.customerReferenceNumber,
    this.amount,
    required this.id,
    this.originalIntentId,
    this.status,
    required this.type,
    this.createdAt,
    this.completedAt,
    this.cancelledAt,
    this.transactions,
  });

  factory Intent.fromJson(Map<String, dynamic> json) {
    String? str(List<String> keys) {
      return toStringSafe(pickKey(json, keys));
    }

    String req(List<String> keys, String fieldName) {
      final v = toStringSafe(pickKey(json, keys));
      if (v.isEmpty) {
        throw StateError('Missing required field: $fieldName');
      }
      return v;
    }

    return Intent(
        terminalId: str([
          'terminalID',
          'terminal_id',
        ]),
        customerReferenceNumber: str([
          'customerReferenceNumber',
          'customer_reference_number',
        ]),
        amount: str(['amount']),
        id: req(['id'], 'id'),
        originalIntentId: str([
          'originalIntentId',
          'originalIntentID',
          'original_intent_id',
        ]),
        status: str(['status']),
        type: req(['type'], 'type'),
        createdAt: str(['createdAt', 'created_at']),
        completedAt: str(['completedAt', 'completed_at']),
        cancelledAt: str(['cancelledAt', 'cancelled_at']),
        transactions: (json['transactions'] as List<dynamic>?)
            ?.map((e) => IntentTransaction.fromJson(e as Map<String, dynamic>))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'status': status,
        'amount': amount,
        'terminal_id': terminalId,
        'customer_reference_number': customerReferenceNumber,
        'original_intent_id': originalIntentId,
        'created_at': createdAt,
        'completed_at': completedAt,
        'cancelled_at': cancelledAt,
        'transactions': transactions?.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() =>
      'Intent(id: $id, type: $type, status: $status, amount: $amount, '
      'customerReferenceNumber: $customerReferenceNumber, '
      'originalIntentId: $originalIntentId, createdAt: $createdAt, '
      'completedAt: $completedAt, cancelledAt: $cancelledAt)';
}

class Currency {
  final String arabic;
  final String english;

  Currency({
    required this.arabic,
    required this.english,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'arabic': arabic,
        'english': english,
      };
}

class Performance {
  final String type;
  final num timeStamp;

  Performance({
    required this.type,
    required this.timeStamp,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
        type: json['type'] as String? ?? '',
        timeStamp: (json['timeStamp'] as num?)?.toInt() ?? 0);
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'timeStamp': timeStamp,
      };
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalData;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalData,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage:
          (pickKey(json, ['current_page', 'currentPage']) as num?)?.toInt() ??
              0,
      totalPages:
          (pickKey(json, ['total_pages', 'totalPages']) as num?)?.toInt() ?? 0,
      totalData:
          (pickKey(json, ['total_data', 'totalData']) as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'total_pages': totalPages,
        'total_data': totalData,
      };
}

class IntentTransaction {
  final String uuid;
  final String? pan;
  final LanguageContent? scheme;
  final String? amountAuthorized;
  final CurrencyDto? currency;
  final bool? isApproved;
  final bool? isReversed;
  final String? retrievalReferenceNumber;
  final String? customerReferenceNumber;

  IntentTransaction(
      {required this.uuid,
      this.pan,
      this.scheme,
      this.amountAuthorized,
      this.currency,
      this.isApproved,
      this.retrievalReferenceNumber,
      this.customerReferenceNumber,
      this.isReversed});

  factory IntentTransaction.fromJson(Map<String, dynamic> json) {
    return IntentTransaction(
      uuid: json['uuid'] as String? ?? '',
      pan: json['pan'] as String?,
      scheme: json['scheme'] != null
          ? LanguageContent.fromJson(json['scheme'] as Map<String, dynamic>)
          : null,
      amountAuthorized:
          pickKey(json, ['amountAuthorized', 'amount_authorized']) as String?,
      currency: json['currency'] != null
          ? CurrencyDto.fromJson(json['currency'] as Map<String, dynamic>)
          : null,
      isApproved: pickKey(json, ['isApproved', 'is_approved']) as bool?,
      isReversed: pickKey(json, ['isReversed', 'is_reversed']) as bool?,
      retrievalReferenceNumber: pickKey(
              json, ['retrievalReferenceNumber', 'retrieval_reference_number'])
          as String?,
      customerReferenceNumber: pickKey(
              json, ['customerReferenceNumber', 'customer_reference_number'])
          as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'pan': pan,
        'scheme': scheme?.toJson(),
        'amount_authorized': amountAuthorized,
        'currency': currency?.toJson(),
        'is_approved': isApproved,
        'is_reversed': isReversed,
        'retrieval_reference_number': retrievalReferenceNumber,
        'customer_reference_number': customerReferenceNumber,
      };
}

class CurrencyDto {
  final String? code;
  final int? decimals;
  final String? name;
  final String? number;

  CurrencyDto({
    this.code,
    this.decimals,
    this.name,
    this.number,
  });

  factory CurrencyDto.fromJson(Map<String, dynamic> json) {
    return CurrencyDto(
      code: json['code'] as String?,
      decimals: (json['decimals'] as num?)?.toInt(),
      name: json['name'] as String?,
      number: json['number'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'decimals': decimals,
        'name': name,
        'number': number,
      };
}

class LanguageContent {
  final String? arabic;
  final String? english;
  final String? turkish;

  LanguageContent({
    this.arabic,
    this.english,
    this.turkish,
  });

  factory LanguageContent.fromJson(Map<String, dynamic> json) {
    return LanguageContent(
      arabic: json['arabic'] as String?,
      english: json['english'] as String?,
      turkish: json['turkish'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'arabic': arabic,
        'english': english,
        'turkish': turkish,
      };
}
