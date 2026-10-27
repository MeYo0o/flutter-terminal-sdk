// intent_details.dart
import '../util/json_pick.dart';
import 'transaction_response.dart';

class IntentDetails {
  final String intentId;
  final String? referenceId;
  final String type;
  final String? status;
  final String? amount;
  final bool pinRequired;
  final String? createdAt;
  final String? completedAt;
  final String? canceledAt;
  final String? receiptsUrl;
  final bool isReconciled;
  final List<TransactionResponse> transactions;

  const IntentDetails({
    required this.intentId,
    this.referenceId,
    required this.type,
    this.status,
    this.amount,
    this.pinRequired = false,
    this.createdAt,
    this.completedAt,
    this.canceledAt,
    this.receiptsUrl,
    this.isReconciled = false,
    required this.transactions,
  });

  factory IntentDetails.fromJson(dynamic json) {
    return IntentDetails(
      intentId: toStringSafe(pickKey(json, ['intentId', 'intent_id'])),
      referenceId: toStringSafe(pickKey(json, ['referenceId', 'reference_id'])),
      type: toStringSafe(pickKey(json, ['type'])),
      status: toStringSafe(json['status']),
      amount: toStringSafe(json['amount']),
      pinRequired: toBoolSafe(pickKey(json, ['pinRequired', 'pin_required'])),
      createdAt: toStringSafe(pickKey(json, ['createdAt', 'created_at'])),
      completedAt: toStringSafe(pickKey(json, ['completedAt', 'completed_at'])),
      canceledAt: toStringSafe(pickKey(
          json, ['canceledAt', 'canceled_at', 'cancelledAt', 'cancelled_at'])),
      receiptsUrl: toStringSafe(pickKey(json, ['receiptsUrl', 'receipts_url'])),
      isReconciled:
          toBoolSafe(pickKey(json, ['isReconciled', 'is_reconciled'])),
      transactions: (json['transactions'] as List<dynamic>? ?? const [])
          .map((e) => TransactionResponse.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intentId': intentId,
      'referenceId': referenceId,
      'type': type,
      'status': status,
      'amount': amount,
      'pinRequired': pinRequired,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'canceledAt': canceledAt,
      'receiptsUrl': receiptsUrl,
      'isReconciled': isReconciled,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  TransactionResponse? getLastTransaction() {
    return transactions.last;
  }

  Receipt? getLastReceipt() {
    return transactions.last.events?[0].receipt;
  }

  @override
  String toString() =>
      'IntentDetails(intentId: $intentId, referenceId: $referenceId, type: $type, '
      'status: $status, amount: $amount, pinRequired: $pinRequired, createdAt: $createdAt, '
      'completedAt: $completedAt, canceledAt: $canceledAt, receiptsUrl: $receiptsUrl, '
      'isReconciled: $isReconciled, transactions: ${transactions.length})';
}
