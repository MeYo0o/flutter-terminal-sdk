// reverse_response.dart

import 'package:flutter_terminal_sdk/domain/models/data/transaction_response.dart';
import '../util/json_pick.dart';

class ReverseResponse {
  final ReverseDetails details;
  final String? status;

  const ReverseResponse({
    required this.details,
    this.status,
  });

  TransactionResponse? getLastTransaction() {
    if (details.transactions?.isNotEmpty == true) {
      return details.transactions?.last;
    }
    return null;
  }

  Receipt? getLastReceipt() {
    final lastTransaction = getLastTransaction();
    return lastTransaction?.events?[0].receipt;
  }

  factory ReverseResponse.fromJson(Map<String, dynamic> json) {
    return ReverseResponse(
      details: ReverseDetails.fromJson(json['details']),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'details': details.toJson(),
        'status': status,
      };

  @override
  String toString() {
    return 'ReverseResponse(details: $details, status: $status)';
  }
}

class ReverseDetails {
  final String? intentId;
  final String? referenceId;
  final String? type;
  final String? status;
  final String? amount;
  final bool? pinRequired;
  final String? createdAt;
  final String? completedAt;
  final String? receiptsUrl;
  final List<TransactionResponse>? transactions;

  const ReverseDetails({
    required this.intentId,
    this.referenceId,
    required this.type,
    this.status,
    this.amount,
    this.pinRequired = false,
    this.createdAt,
    this.completedAt,
    this.receiptsUrl,
    required this.transactions,
  });

  factory ReverseDetails.fromJson(Map<String, dynamic> json) {
    return ReverseDetails(
        intentId: pickKey(json, ['intentId', 'intent_id']),
        referenceId: pickKey(json, ['referenceId', 'reference_id']),
        type: json['type'],
        status: json['status'],
        amount: json['amount'],
        pinRequired: pickKey(json, ['pinRequired', 'pin_required']) ?? false,
        createdAt: pickKey(json, ['createdAt', 'created_at']),
        completedAt: pickKey(json, ['completedAt', 'completed_at']),
        receiptsUrl: pickKey(json, ['receiptsUrl', 'receipts_url']),
        transactions: (json['transactions'] as List<dynamic>? ?? const [])
            .map((e) => TransactionResponse.fromJson(e))
            .toList(growable: false));
  }

  Map<String, dynamic> toJson() => {
        'intent_id': intentId,
        'reference_id': referenceId,
        'type': type,
        'status': status,
        'amount': amount,
        'pin_required': pinRequired,
        'created_at': createdAt,
        'completed_at': completedAt,
        'receipts_url': receiptsUrl,
        'transactions': transactions?.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() =>
      'ReverseDetails(intentId: $intentId, referenceId: $referenceId, type: $type, '
      'status: $status, amount: $amount, pinRequired: $pinRequired, '
      'createdAt: $createdAt, completedAt: $completedAt, '
      'receiptsUrl: $receiptsUrl, transactions: ${transactions?.length})';
}
