import 'package:flutter/services.dart';
import '../util/json_pick.dart';
import '../util/receipt_image.dart';
import '../util/receipt_parsers.dart';
import 'dto/LocalizationField.dart';
import 'dto/currency_content.dart';
import 'dto/transaction_response_turkey.dart';
import 'dto/transaction_response_usa.dart';
import 'dto/language_content.dart';
import 'merchant.dart' as mr;

part 'transaction_response_receipt_data.dart';
part 'transaction_response_dtos.dart';

class TransactionResponse {
  final String? id;
  final String? referenceId;
  final String? orderId;
  final List<PerformanceDto>? performance;
  final String? cancelReason;
  final String? status;
  final String? amount;
  final CurrencyContent? currency;
  final String? createdAt;
  final String? completedAt;

  final bool? pinRequired;
  final dynamic card;
  final List<Event>? events;
  final String? amountOther;

  TransactionResponse({
    required this.id,
    this.performance,
    this.cancelReason,
    this.status,
    this.amount,
    this.currency,
    this.createdAt,
    this.completedAt,
    this.referenceId,
    this.orderId,
    this.pinRequired,
    required this.card,
    required this.events,
    required this.amountOther,
  });

  factory TransactionResponse.fromJson(dynamic json) {
    var performanceList = json['performance'] as List?;
    List<PerformanceDto>? performanceItems;

    if (performanceList != null) {
      performanceItems = performanceList.map((item) {
        return PerformanceDto.fromJson(item);
      }).toList();
    }

    var eventList = json['events'] as List;
    List<Event> eventItems =
        eventList.map((item) => Event.fromJson(item)).toList();

    final rawCurrency = pickKey(json, ['currency']);
    CurrencyContent? currencyContent;
    if (rawCurrency is Map) {
      currencyContent = CurrencyContent.fromJson(rawCurrency);
    } else if (rawCurrency is String && rawCurrency.isNotEmpty) {
      currencyContent = CurrencyContent(
        english: rawCurrency,
        arabic: rawCurrency,
        turkish: rawCurrency,
      );
    }

    return TransactionResponse(
      id: json['id'],
      performance: performanceItems,
      cancelReason: pickKey(json, ['cancelReason', 'cancel_reason']),
      status: json['status'],
      amount: pickKey(json, ['amount'])?.toString(),
      currency: currencyContent,
      createdAt: pickKey(json, ['createdAt', 'created_at']),
      completedAt: pickKey(json, ['completedAt', 'completed_at']),
      referenceId: pickKey(json, ['referenceId', 'reference_id']),
      orderId: pickKey(json, ['orderId', 'order_id']),
      pinRequired: pickKey(json, ['pinRequired', 'pin_required']),
      card: json['card'] != null ? Map.from(json['card']) : {},
      events: eventItems,
      amountOther: pickKey(json, ['amountOther', 'amount_other']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'performance': performance?.map((e) => e.toJson()).toList(),
      'cancelReason': cancelReason,
      'status': status,
      'amount': amount,
      'currency': currency?.toJson(),
      'createdAt': createdAt,
      'completedAt': completedAt,
      'referenceId': referenceId,
      'orderId': orderId,
      'pinRequired': pinRequired,
      'card': card,
      'events': events?.map((e) => e.toJson()).toList(),
      'amountOther': amountOther,
    };
  }
}

class PerformanceDto {
  final String? type;
  final double? timeStamp;

  PerformanceDto({required this.type, required this.timeStamp});

  factory PerformanceDto.fromJson(dynamic json) {
    return PerformanceDto(
      type: json['type'],
      timeStamp: pickKey(json, ['timeStamp', 'time_stamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timeStamp': timeStamp,
    };
  }
}

class Event {
  final Receipt? receipt;
  final String? rrn;
  final String? status;

  Event({required this.receipt, required this.rrn, required this.status});

  factory Event.fromJson(dynamic json) {
    return Event(
      receipt: Receipt.fromJson(json['receipt']),
      rrn: json['rrn'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receipt': receipt?.toJson(),
      'rrn': rrn,
      'status': status,
    };
  }
}

class Receipt {
  final String? standard;
  final String? id;
  final dynamic data;

  Receipt({
    required this.standard,
    required this.id,
    required this.data,
  });

  factory Receipt.fromJson(dynamic json) {
    return Receipt(
      standard: json['standard'] as String?,
      id: json['id'] as String?,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standard': standard,
      'id': id,
      'data': data,
    };
  }

  ReceiptDataTurkey? getBKMReceipt() => parseBkmReceipt(data);

  AuthorizeReceipt? getEPXReceipt() => parseEpxReceipt(data);

  ReceiptData? getMadaReceipt() {
    try {
      final normalized = normalizeMadaReceiptPayload(data);
      if (normalized == null) return null;
      return ReceiptData.fromMadaJson(normalized);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Receipt(standard: $standard, id: $id, data: $data)';
  }
}
