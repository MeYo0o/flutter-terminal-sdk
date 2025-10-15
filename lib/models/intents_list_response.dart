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
}

// intent.dart

/// Note: If the name `Intent` clashes with Flutter's Actions/Shortcuts API
/// in your imports, consider renaming to `TerminalIntent` or prefixing imports.
class Intent {
  final String? customerReferenceNumber;
  final String? amount;
  final String id;
  final String? originalIntentId; // Kotlin: originalIntentID
  final String? status;
  final String type;
  final String? createdAt;
  final String? completedAt;
  final String? cancelledAt;

  const Intent({
    this.customerReferenceNumber,
    this.amount,
    required this.id,
    this.originalIntentId,
    this.status,
    required this.type,
    this.createdAt,
    this.completedAt,
    this.cancelledAt,
  });

  /// Flexible factory:
  /// - Accepts both camelCase and snake_case keys.
  /// - Also tolerates `originalIntentID` (all-caps ID) from some payloads.
  factory Intent.fromJson(Map<String, dynamic> json) {
    String? _str(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v == null) continue;
        if (v is String) return v;
      }
      return null;
    }

    String _req(List<String> keys, String fieldName) {
      final v = _str(keys);
      if (v == null) {
        throw StateError('Missing required field: $fieldName');
      }
      return v;
    }

    return Intent(
      customerReferenceNumber: _str([
        'customerReferenceNumber',
        'customer_reference_number',
      ]),
      amount: _str(['amount']),
      id: _req(['id'], 'id'),
      originalIntentId: _str([
        'originalIntentId',
        'originalIntentID', // tolerate Kotlin-style ID suffix
        'original_intent_id',
      ]),
      status: _str(['status']),
      type: _req(['type'], 'type'),
      createdAt: _str(['createdAt', 'created_at']),
      completedAt: _str(['completedAt', 'completed_at']),
      cancelledAt: _str(['cancelledAt', 'cancelled_at']),
    );
  }

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
  final num timeStamp; // Ensure it's int

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
      currentPage: (json['current_page'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      totalData: (json['total_data'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'total_pages': totalPages,
        'total_data': totalData,
      };
}
