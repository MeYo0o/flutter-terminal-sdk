import 'package:flutter_terminal_sdk/domain/models/data/transaction_response.dart';

import 'intent_details.dart';

class IncrementResponse {
  final IntentDetails? details;
  final String? status;

  const IncrementResponse({
    required this.details,
    required this.status,
  });

  factory IncrementResponse.fromJson(dynamic json) {
    return IncrementResponse(
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

  Map<String, dynamic> toJson() => {
        'details': details?.toJson(),
        'status': status,
      };

  @override
  String toString() => 'IncrementResponse(details: $details, status: $status)';
}
