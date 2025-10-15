import 'package:flutter_terminal_sdk/models/data/scheme.dart';

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
  final Details details;
  final LanguageContent currency;
  final String systemTraceAuditNumber;

  ReconciliationResponse({
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
    required this.details,
    required this.currency,
    required this.systemTraceAuditNumber,
  });

  factory ReconciliationResponse.fromJson(Map<String, dynamic> json) {
    return ReconciliationResponse(
      id: json['id'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      startDate: json['startDate'] as String,
      startTime: json['startTime'] as String,
      endDate: json['endDate'] as String,
      endTime: json['endTime'] as String,
      merchant: Merchant.fromJson(json['merchant'] as Map<String, dynamic>),
      cardAcceptorTerminalId: json['cardAcceptorTerminalId'] as String,
      posSoftwareVersionNumber: json['posSoftwareVersionNumber'] as String,
      cardSchemeSponsorId: json['cardSchemeSponsorId'] as String,
      isBalanced:
          LabelValue.fromJson(json['isBalanced'] as Map<String, dynamic>),
      schemes: (json['schemes'] as List<dynamic>)
          .map((e) => Scheme.fromJson(e as Map<String, dynamic>))
          .toList(),
      details: Details.fromJson(json['details'] as Map<String, dynamic>),
      currency:
          LanguageContent.fromJson(json['currency'] as Map<String, dynamic>),
      systemTraceAuditNumber: json['systemTraceAuditNumber'] as String,
    );
  }

}
