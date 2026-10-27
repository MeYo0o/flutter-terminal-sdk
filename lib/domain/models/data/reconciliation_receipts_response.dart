import 'dart:convert';
import 'dart:typed_data';

import '../util/json_pick.dart';
import '../util/receipt_image.dart';

class ReconciliationReceiptsResponse {
  ReconciliationReceipt? receipt;
  String? reconciliationId;

  ReconciliationReceiptsResponse({
    this.receipt,
    this.reconciliationId,
  });

  factory ReconciliationReceiptsResponse.fromJson(Map<String, dynamic> json) {
    return ReconciliationReceiptsResponse(
      receipt: json['receipt'] != null
          ? ReconciliationReceipt.fromJson(
              Map<String, dynamic>.from(json['receipt'] as Map),
            )
          : null,
      reconciliationId: toStringSafe(
        pickKey(json, ['reconciliation_id', 'reconciliationId']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'receipt': receipt?.toJson(),
        'reconciliation_id': reconciliationId,
      };
}

class ReconciliationReceipt {
  final String id;
  final String standard;
  final String operationType;
  final dynamic data;
  final Reconciliation reconciliation;
  final String createdAt;
  final String updatedAt;

  ReconciliationReceipt({
    required this.id,
    required this.standard,
    required this.operationType,
    this.data,
    required this.reconciliation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReconciliationReceipt.fromJson(Map<String, dynamic> json) {
    return ReconciliationReceipt(
      id: toStringSafe(json['id']),
      standard: toStringSafe(json['standard']),
      operationType:
          toStringSafe(pickKey(json, ['operationType', 'operation_type'])),
      data: json['data'],
      reconciliation: Reconciliation.fromJson(
        Map<String, dynamic>.from(json['reconciliation'] as Map),
      ),
      createdAt: toStringSafe(pickKey(json, ['createdAt', 'created_at'])),
      updatedAt: toStringSafe(pickKey(json, ['updatedAt', 'updated_at'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'standard': standard,
      'operationType': operationType,
      'data': data,
      'reconciliation': reconciliation.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Future<Uint8List> toImage({
    int? receiptWidth,
    int? fontSize,
  }) {
    final payload = data is String ? jsonDecode(data as String) : data;
    if (payload == null) {
      throw StateError('Reconciliation receipt data is missing');
    }
    return renderReceiptImage(
      payload,
      receiptWidth: receiptWidth,
      fontSize: fontSize,
      receiptType: 'reconciliation',
    );
  }
}

class Reconciliation {
  String? id;

  Reconciliation({this.id});

  factory Reconciliation.fromJson(Map<String, dynamic> json) {
    return Reconciliation(
      id: toStringSafe(json['id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
