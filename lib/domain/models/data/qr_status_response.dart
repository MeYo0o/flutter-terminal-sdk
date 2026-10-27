// intent_details.dart
import 'transaction_response.dart';

class QrStatusResponse {
  final String? id;
  final String statusRaw;
  final String? message;
  final String? authCode;
  final String? actionCode;
  final String? rrn;
  final String? stan;
  final String? amount;
  final Receipt? receipt;
  final Status? status;

  const QrStatusResponse({
    this.id,
    required this.statusRaw,
    this.message,
    this.authCode,
    this.actionCode,
    this.rrn,
    this.stan,
    this.amount,
    this.receipt,
    this.status,
  });

  factory QrStatusResponse.fromJson(dynamic json) {
    return QrStatusResponse(
      id: json['id'] as String?,
      statusRaw: json['statusRaw'] as String,
      message: json['message'] as String?,
      authCode: json['authCode'] as String?,
      actionCode: json['actionCode'] as String?,
      rrn: json['rrn'] as String?,
      stan: json['stan'] as String?,
      amount: json['amount'] as String?,
      status: Status.from(json['statusRaw'] as String?),
      receipt:
          json['receipt'] != null ? Receipt.fromJson(json['receipt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'statusRaw': statusRaw,
        'status': status?.name,
        'message': message,
        'authCode': authCode,
        'actionCode': actionCode,
        'rrn': rrn,
        'stan': stan,
        'amount': amount,
        'receipt': receipt?.toJson(),
      };

  @override
  String toString() {
    return 'QrStatusResponse(id: $id, statusRaw: $statusRaw, message: $message, authCode: $authCode, actionCode: $actionCode, rrn: $rrn, stan: $stan, amount: $amount, receipt: $receipt)';
  }
}

enum Status {
  enquiring,
  processing,
  completed,
  failed,
  expired;

  static Status? from(String? raw) {
    if (raw == null) return null;

    final normalized = raw.trim().toUpperCase();

    for (final status in Status.values) {
      if (status.name.toUpperCase() == normalized) {
        return status;
      }
    }

    switch (normalized) {
      case 'APPROVED':
        return Status.completed;
      case 'DECLINED':
        return Status.failed;
      default:
        return null;
    }
  }
}
