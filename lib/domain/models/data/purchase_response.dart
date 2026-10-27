import 'package:flutter_terminal_sdk/domain/models/data/transaction_response.dart';

import 'intent_details.dart';

class PurchaseResponse {
  final IntentDetails? details;
  final String? status;

  const PurchaseResponse({
    required this.details,
    required this.status,
  });

  factory PurchaseResponse.fromJson(dynamic json) {
    return PurchaseResponse(
      details: IntentDetails.fromJson(json['details']),
      status: json['status'] as String?,
    );
  }

  TransactionResponse? getLastTransaction() {
    return details?.transactions.last;
  }

  Receipt? getLastReceipt() {
    return details?.transactions.last.events?[0].receipt;
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details?.toJson(),
      'status': status,
    };
  }

  @override
  String toString() => 'PurchaseResponse(details: $details, status: $status)';
}
