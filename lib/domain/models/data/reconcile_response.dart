import 'dart:typed_data';

import 'package:flutter_terminal_sdk/domain/models/data/scheme.dart';

import '../util/json_pick.dart';
import '../util/receipt_image.dart';
import 'details.dart';
import 'label_value.dart';
import 'dto/language_content.dart';
import 'merchant.dart';

class ReconciliationResponse {
  final String id;
  final String date;
  final String time;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final Merchant merchant;
  final String cardAcceptorTerminalId;
  final String posSoftwareVersionNumber;
  final String cardSchemeSponsorId;
  final LabelValue<bool> isBalanced;
  final List<Scheme> schemes;

  final Details detailsDTO;
  final LanguageContent currency;
  final String systemTraceAuditNumber;

  final String? merchantId;
  final String? deviceId;
  final String? clientId;
  final ID? terminal;
  final Reconciliation? reconciliation;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;
  final String? qrCode;

  const ReconciliationResponse({
    required this.id,
    required this.date,
    required this.time,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.merchant,
    required this.cardAcceptorTerminalId,
    required this.posSoftwareVersionNumber,
    required this.cardSchemeSponsorId,
    required this.isBalanced,
    required this.schemes,
    required this.detailsDTO,
    required this.currency,
    required this.systemTraceAuditNumber,
    this.merchantId,
    this.deviceId,
    this.clientId,
    this.terminal,
    this.reconciliation,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.qrCode,
  });

  factory ReconciliationResponse.fromJson(Map<String, dynamic> json) {
    final detailsJson =
        (json['detailsDTO'] ?? json['details']) as Map<String, dynamic>;

    return ReconciliationResponse(
      id: toStringSafe(json['id']),
      date: toStringSafe(json['date']),
      time: toStringSafe(json['time']),
      startDate: toStringSafe(pickKey(json, ['startDate', 'start_date'])),
      startTime: toStringSafe(pickKey(json, ['startTime', 'start_time'])),
      endDate: toStringSafe(pickKey(json, ['endDate', 'end_date'])),
      endTime: toStringSafe(pickKey(json, ['endTime', 'end_time'])),
      merchant: Merchant.fromJson(json['merchant'] as Map<String, dynamic>),
      cardAcceptorTerminalId: toStringSafe(pickKey(
          json, ['cardAcceptorTerminalId', 'card_acceptor_terminal_id'])),
      posSoftwareVersionNumber: toStringSafe(pickKey(
          json, ['posSoftwareVersionNumber', 'pos_software_version_number'])),
      cardSchemeSponsorId: toStringSafe(
          pickKey(json, ['cardSchemeSponsorId', 'card_scheme_sponsor_id'])),
      isBalanced: LabelValue.boolFromJson(Map<String, dynamic>.from(
          pickKey(json, ['isBalanced', 'is_balanced']) as Map)),
      schemes: ((json['schemes'] as List<dynamic>?) ?? const [])
          .map((e) => Scheme.fromJson(e as Map<String, dynamic>))
          .toList(),
      detailsDTO: Details.fromJson(detailsJson),
      currency:
          LanguageContent.fromJson(json['currency'] as Map<String, dynamic>),
      systemTraceAuditNumber: toStringSafe(pickKey(
          json, ['systemTraceAuditNumber', 'system_trace_audit_number'])),
      merchantId: pickKey(json, ['merchantId', 'merchant_id']) == null
          ? null
          : toStringSafe(pickKey(json, ['merchantId', 'merchant_id'])),
      deviceId: pickKey(json, ['deviceId', 'device_id']) == null
          ? null
          : toStringSafe(pickKey(json, ['deviceId', 'device_id'])),
      clientId: pickKey(json, ['clientId', 'client_id']) == null
          ? null
          : toStringSafe(pickKey(json, ['clientId', 'client_id'])),
      terminal: json['terminal'] == null
          ? null
          : ID.fromJson(json['terminal'] as Map<String, dynamic>),
      reconciliation: json['reconciliation'] == null
          ? null
          : Reconciliation.fromJson(
              json['reconciliation'] as Map<String, dynamic>),
      userId: pickKey(json, ['userId', 'user_id']) == null
          ? null
          : toStringSafe(pickKey(json, ['userId', 'user_id'])),
      createdAt: pickKey(json, ['createdAt', 'created_at']) == null
          ? null
          : toStringSafe(pickKey(json, ['createdAt', 'created_at'])),
      updatedAt: pickKey(json, ['updatedAt', 'updated_at']) == null
          ? null
          : toStringSafe(pickKey(json, ['updatedAt', 'updated_at'])),
      qrCode: pickKey(json, ['qrCode', 'qr_code']) == null
          ? null
          : toStringSafe(pickKey(json, ['qrCode', 'qr_code'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'start_date': startDate,
        'start_time': startTime,
        'end_date': endDate,
        'end_time': endTime,
        'merchant': merchant.toJson(),
        'card_acceptor_terminal_id': cardAcceptorTerminalId,
        'pos_software_version_number': posSoftwareVersionNumber,
        'card_scheme_sponsor_id': cardSchemeSponsorId,
        'is_balanced': isBalanced.toJson(),
        'schemes': schemes.map((e) => e.toJson()).toList(),
        'details': detailsDTO.toJson(),
        'currency': currency.toJson(),
        'system_trace_audit_number': systemTraceAuditNumber,
        'merchant_id': merchantId,
        'device_id': deviceId,
        'client_id': clientId,
        'terminal': terminal?.toJson(),
        'reconciliation': reconciliation?.toJson(),
        'user_id': userId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'qr_code': qrCode,
      };

  Future<Uint8List> toImage({
    int? receiptWidth,
    int? fontSize,
  }) =>
      renderReceiptImage(
        toJson(),
        receiptWidth: receiptWidth,
        fontSize: fontSize,
        receiptType: 'reconciliation',
      );
}

class ID {
  final String id;

  const ID({required this.id});

  factory ID.fromJson(Map<String, dynamic> json) {
    return ID(
      id: toStringSafe(json['id']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class Reconciliation {
  final String id;

  const Reconciliation({required this.id});

  factory Reconciliation.fromJson(Map<String, dynamic> json) {
    return Reconciliation(
      id: toStringSafe(json['id']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id};
}
