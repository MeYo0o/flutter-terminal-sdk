import 'dart:convert';

import 'package:flutter_terminal_sdk/models/data/dto/currency_content.dart';

// Define the main response object
class TransactionResponseTurkey {
  final String? id;
  final List<PerformanceDto>? performance;
  final String? cancelReason;
  final String? status;
  final CurrencyContent? currency;
  final String? createdAt;
  final String? completedAt;
  final String? referenceId;
  final String? orderId;
  final bool? pinRequired;
  final dynamic card;
  final List<Event>? events;
  final String? amountOther;

  TransactionResponseTurkey({
    required this.id,
    this.performance,
    this.cancelReason,
    this.status,
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

  ReceiptDataTurkey getBKMReceipt() {
    if (events![0].receipt!.data == null) {
      throw Exception("Data is null");
    }
    return ReceiptDataTurkey.fromJson(jsonDecode(events![0].receipt!.data!));
  }

  factory TransactionResponseTurkey.fromJson(dynamic json) {
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

    return TransactionResponseTurkey(
      id: json['id'],
      performance: performanceItems,
      cancelReason: json['cancelReason'],
      status: json['status'],
      currency: json['currency'] != null
          ? CurrencyContent.fromJson(json['currency'])
          : null,
      createdAt: json['createdAt'],
      completedAt: json['completedAt'],
      referenceId: json['referenceId'],
      orderId: json['orderId'],
      pinRequired: json['pinRequired'],
      card: json['card'] != null ? Map.from(json['card']) : {},
      events: eventItems,
      amountOther: json['amountOther'],
    );
  }
}

// Define the PerformanceDto object
class PerformanceDto {
  final String? type;
  final double? timeStamp;

  PerformanceDto({required this.type, required this.timeStamp});

  factory PerformanceDto.fromJson(dynamic json) {
    return PerformanceDto(
      type: json['type'],
      timeStamp: json['timeStamp'],
    );
  }
}

// Define the Event object
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
}

// Define the Receipt class
class Receipt {
  final String? standard;
  final String? id;
  final String? data;

  Receipt({
    required this.standard,
    required this.id,
    required this.data,
  });

  factory Receipt.fromJson(dynamic json) {
    return Receipt(
      standard: json['standard'],
      id: json['id'],
      data: json['data'],
    );
  }
}

class ReceiptDataTurkey {
  final String? id;
  final String? pan;
  final String? tid;
  final String? type;
  final String? date;
  final String? time;
  final String? cardType;
  final CurrencyContent? currency;
  final Merchant? merchant;
  final LocalizedText? pinUsed;
  final String? panSuffix;
  final String? acquirerId;
  final String? actionCode;
  final String? cardScheme;
  final String? cardDomain;
  final bool? isApproved;
  final String? batchNumber;
  final String? acquirerName;
  final String? approvalCode;
  final String? serialNumber;
  final String? bankReference;
  final String? deviceDetails;
  final LocalizedText? statusMessage;
  final String? cardExpiration;
  final String? transactionCode;
  final TransactionType? transactionType;
  final String? transactionUuid;
  final AmountAuthorized? amountAuthorized;
  final String? transactionNumber;
  final LocalizedText? actionCodeMessage;
  final String? cardSchemeSponsor;
  final LocalizedText? transactionDetails;
  final String? applicationCryptogram;
  final String? applicationIdentifier;
  final String? paymentAccountReference;
  final String? systemTraceAuditNumber;
  final String? retrievalReferenceNumber;
  final String? cryptogramInformationData;
  final String? posSoftwareVersionNumber;
  final String? qrCode;
  final String? transactionStateInformation;
  final String? cardholderVerificationResult;

  ReceiptDataTurkey({
    this.id,
    this.pan,
    this.tid,
    this.type,
    this.date,
    this.time,
    this.cardType,
    this.currency,
    this.merchant,
    this.pinUsed,
    this.panSuffix,
    this.acquirerId,
    this.actionCode,
    this.cardScheme,
    this.cardDomain,
    this.isApproved,
    this.batchNumber,
    this.acquirerName,
    this.approvalCode,
    this.serialNumber,
    this.bankReference,
    this.deviceDetails,
    this.statusMessage,
    this.cardExpiration,
    this.transactionCode,
    this.transactionType,
    this.transactionUuid,
    this.amountAuthorized,
    this.transactionNumber,
    this.actionCodeMessage,
    this.cardSchemeSponsor,
    this.transactionDetails,
    this.applicationCryptogram,
    this.applicationIdentifier,
    this.paymentAccountReference,
    this.systemTraceAuditNumber,
    this.retrievalReferenceNumber,
    this.cryptogramInformationData,
    this.posSoftwareVersionNumber,
    this.qrCode,
    this.transactionStateInformation,
    this.cardholderVerificationResult,
  });

  factory ReceiptDataTurkey.fromJson(dynamic json) {
    return ReceiptDataTurkey(
      id: json['id'],
      pan: json['pan'],
      tid: json['tid'],
      type: json['type'],
      date: json['date'],
      time: json['time'],
      cardType: json['card_type'],
      currency: json['currency'] != null
          ? CurrencyContent.fromJson(json['currency'])
          : null,
      merchant:
          json['merchant'] != null ? Merchant.fromJson(json['merchant']) : null,
      pinUsed: json['pinUsed'] != null
          ? LocalizedText.fromJson(json['pin_used'])
          : null,
      panSuffix: json['pan_suffix'],
      acquirerId: json['acquirer_id'],
      actionCode: json['action_code'],
      cardScheme: json['card_scheme'],
      cardDomain: json['card_domain'],
      isApproved: json['is_approved'],
      batchNumber: json['batch_number'],
      acquirerName: json['acquirer_name'],
      approvalCode: json['approval_code'],
      serialNumber: json['serial_number'],
      bankReference: json['bank_reference'],
      deviceDetails: json['device_details'],
      statusMessage: json['status_message'] != null
          ? LocalizedText.fromJson(json['status_message'])
          : null,
      cardExpiration: json['card_expiration'],
      transactionCode: json['transaction_code'],
      transactionType: json['transaction_type'] != null
          ? TransactionType.fromJson(json['transaction_type'])
          : null,
      transactionUuid: json['transaction_uuid'],
      amountAuthorized: json['amount_authorized'] != null
          ? AmountAuthorized.fromJson(json['amount_authorized'])
          : null,
      transactionNumber: json['transaction_number'],
      actionCodeMessage: json['action_code_message'] != null
          ? LocalizedText.fromJson(json['action_code_message'])
          : null,
      cardSchemeSponsor: json['card_scheme_sponsor'],
      transactionDetails: json['transaction_details'] != null
          ? LocalizedText.fromJson(json['transaction_details'])
          : null,
      applicationCryptogram: json['application_cryptogram'],
      applicationIdentifier: json['application_identifier'],
      paymentAccountReference: json['payment_account_reference'],
      systemTraceAuditNumber: json['system_trace_audit_number'],
      retrievalReferenceNumber: json['retrieval_reference_number'],
      cryptogramInformationData: json['cryptogram_information_data'],
      posSoftwareVersionNumber: json['pos_software_version_number'],
      qrCode: json['qr_code'],
      transactionStateInformation: json['transaction_state_information'],
      cardholderVerificationResult: json['cardholder_verification_result'],
    );
  }

  @override
  String toString() {
    return 'ReceiptDataTurkey(id: $id, pan: $pan, tid: $tid, type: $type, date: $date, time: $time, cardType: $cardType, currency: $currency, merchant: $merchant, pinUsed: $pinUsed, panSuffix: $panSuffix, acquirerId: $acquirerId, actionCode: $actionCode, cardScheme: $cardScheme, cardDomain: $cardDomain, isApproved: $isApproved, batchNumber: $batchNumber, acquirerName: $acquirerName, approvalCode: $approvalCode, serialNumber: $serialNumber, bankReference: $bankReference, deviceDetails: $deviceDetails, statusMessage: $statusMessage, cardExpiration: $cardExpiration, transactionCode: $transactionCode, transactionType: $transactionType, transactionUuid: $transactionUuid, amountAuthorized: $amountAuthorized, transactionNumber: $transactionNumber, actionCodeMessage: $actionCodeMessage, cardSchemeSponsor: $cardSchemeSponsor, transactionDetails: $transactionDetails, applicationCryptogram: $applicationCryptogram, applicationIdentifier: $applicationIdentifier, paymentAccountReference: $paymentAccountReference, systemTraceAuditNumber: $systemTraceAuditNumber, retrievalReferenceNumber: $retrievalReferenceNumber, cryptogramInformationData: $cryptogramInformationData, posSoftwareVersionNumber: $posSoftwareVersionNumber, qrCode: $qrCode, transactionStateInformation: $transactionStateInformation, cardholderVerificationResult: $cardholderVerificationResult)';
  }
}

// Define the Merchant class
class Merchant {
  final String? id;
  final String? name;
  final String? address;

  Merchant({
    required this.id,
    required this.name,
    required this.address,
  });

  factory Merchant.fromJson(dynamic json) {
    return Merchant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }
}

// Define the LocalizedText class
class LocalizedText {
  final String? english;
  final String? turkish;

  LocalizedText({
    required this.english,
    required this.turkish,
  });

  factory LocalizedText.fromJson(dynamic json) {
    return LocalizedText(
      english: json['english'],
      turkish: json['turkish'],
    );
  }
}

// Define the TransactionType class
class TransactionType {
  final String? id;
  final LocalizedText? name;

  TransactionType({
    required this.id,
    required this.name,
  });

  factory TransactionType.fromJson(dynamic json) {
    return TransactionType(
      id: json['id'],
      name: LocalizedText.fromJson(json['name']),
    );
  }
}

// Define the AmountAuthorized class
class AmountAuthorized {
  final LocalizedText? label;
  final String? value;

  AmountAuthorized({
    required this.label,
    required this.value,
  });

  factory AmountAuthorized.fromJson(dynamic json) {
    return AmountAuthorized(
      label: LocalizedText.fromJson(json['label']),
      value: json['value'],
    );
  }
}
