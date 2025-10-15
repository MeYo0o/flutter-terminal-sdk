import 'dart:convert';

import 'dto/currency_content.dart';
import 'dto/transaction_response_turkey.dart';
import 'dto/transaction_response_usa.dart';
import 'dto/language_content.dart';
import 'merchant.dart' as mr;

// Define the main response object
class TransactionResponse {
  final String? id;
  final String? referenceId;
  final String? orderId;
  final List<PerformanceDto>? performance;
  final String? cancelReason;
  final String? status;
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

    return TransactionResponse(
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

  ReceiptDataTurkey getBKMReceipt() {
    if (data == null) {
      throw Exception("Data is null");
    }
    try {
      return ReceiptDataTurkey.fromJson(jsonDecode(data!));
    } catch (e) {
      throw Exception("Error parsing BKM receipt: $e");
    }
  }

  AuthorizeReceipt getEPXReceipt() {
    if (data == null) {
      throw Exception("Data is null");
    }
    try {
      return AuthorizeReceipt.fromJson(jsonDecode(data!));
    } catch (e) {
      throw Exception("Error parsing EPX receipt: $e");
    }
  }

  ReceiptData getMadaReceipt() {
    if (data == null) {
      throw Exception("Data is null");
    }
    try {
      return ReceiptData.fromMadaJson(jsonDecode(data!));
    } catch (e) {
      throw Exception("Error parsing Mada receipt: $e");
    }
  }
}


String? _nullIfEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s;

class ReceiptData {
  final String id;
  final mr.Merchant merchant;
  final CardScheme cardScheme;
  final String cardSchemeSponsor;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String terminalId;
  final String systemTraceAuditNumber;
  final String posSoftwareVersion;
  final String retrievalReferenceNumber;
  final TransactionType transactionType;
  final bool isApproved;
  final bool isRefunded;
  final bool isReversed;
  final ApprovalCode? approvalCode;
  final String actionCode;
  final CurrencyContent statusMessage;
  final String pan;
  final String cardExpiration;
  final LabelField<String> amountAuthorized;
  final LabelField<String> amountOther;
  final CurrencyContent currency;
  final CurrencyContent verificationMethod;
  final CurrencyContent receiptLineOne;
  final CurrencyContent receiptLineTwo;
  final CurrencyContent thanksMessage;
  final CurrencyContent saveReceiptMessage;
  final String entryMode;
  final String applicationIdentifier;
  final String terminalVerificationResult;
  final String transactionStateInformation;
  final String cardholderVerificationResult; // note: JSON had a typo key
  final String cryptogramInformationData;
  final String applicationCryptogram;
  final String kernelId;
  final String? paymentAccountReference;
  final String? panSuffix;
  final String? customerReferenceNumber;
  final String qrCode;
  final String transactionUuid;
  final String? vasData;

  const ReceiptData({
    required this.id,
    required this.merchant,
    required this.cardScheme,
    required this.cardSchemeSponsor,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.terminalId,
    required this.systemTraceAuditNumber,
    required this.posSoftwareVersion,
    required this.retrievalReferenceNumber,
    required this.transactionType,
    required this.isApproved,
    required this.isRefunded,
    required this.isReversed,
    this.approvalCode,
    required this.actionCode,
    required this.statusMessage,
    required this.pan,
    required this.cardExpiration,
    required this.amountAuthorized,
    required this.amountOther,
    required this.currency,
    required this.verificationMethod,
    required this.receiptLineOne,
    required this.receiptLineTwo,
    required this.thanksMessage,
    required this.saveReceiptMessage,
    required this.entryMode,
    required this.applicationIdentifier,
    required this.terminalVerificationResult,
    required this.transactionStateInformation,
    required this.cardholderVerificationResult,
    required this.cryptogramInformationData,
    required this.applicationCryptogram,
    required this.kernelId,
    this.paymentAccountReference,
    this.panSuffix,
    this.customerReferenceNumber,
    required this.qrCode,
    required this.transactionUuid,
    this.vasData,
  });

  /// Factory that maps your snake_case JSON to camelCase fields
  factory ReceiptData.fromMadaJson(Map<String, dynamic> json) {
    return ReceiptData(
      id: json['id'] as String,
      merchant: mr.Merchant.fromJson(json['merchant'] as Map<String, dynamic>),
      cardScheme: CardScheme.fromJson(json['card_scheme'] as Map<String, dynamic>),
      cardSchemeSponsor: json['card_scheme_sponsor'] as String,
      startDate: json['start_date'] as String,
      startTime: json['start_time'] as String,
      endDate: json['end_date'] as String,
      endTime: json['end_time'] as String,
      terminalId: json['tid'] as String,
      systemTraceAuditNumber: json['system_trace_audit_number'] as String,
      posSoftwareVersion: json['pos_software_version_number'] as String,
      retrievalReferenceNumber: json['retrieval_reference_number'] as String,
      transactionType: TransactionType.fromJson(json['transaction_type'] as Map<String, dynamic>),
      isApproved: json['is_approved'] as bool,
      isRefunded: json['is_refunded'] as bool,
      isReversed: json['is_reversed'] as bool,
      approvalCode: (json['approval_code'] == null)
          ? null
          : ApprovalCode.fromJson(json['approval_code'] as Map<String, dynamic>),
      actionCode: json['action_code'] as String,
      statusMessage: CurrencyContent.fromJson(json['status_message'] as Map<String, dynamic>),
      pan: json['pan'] as String,
      cardExpiration: json['card_expiration'] as String,
      amountAuthorized: LabelField<String>.fromJson(json['amount_authorized'] as Map<String, dynamic>),
      amountOther: LabelField<String>.fromJson(json['amount_other'] as Map<String, dynamic>),
      currency: CurrencyContent.fromJson(json['currency'] as Map<String, dynamic>),
      verificationMethod: CurrencyContent.fromJson(json['verification_method'] as Map<String, dynamic>),
      receiptLineOne: CurrencyContent.fromJson(json['receipt_line_one'] as Map<String, dynamic>),
      receiptLineTwo: CurrencyContent.fromJson(json['receipt_line_two'] as Map<String, dynamic>),
      thanksMessage: CurrencyContent.fromJson(json['thanks_message'] as Map<String, dynamic>),
      saveReceiptMessage: CurrencyContent.fromJson(json['save_receipt_message'] as Map<String, dynamic>),
      entryMode: json['entry_mode'] as String,
      applicationIdentifier: json['application_identifier'] as String,
      terminalVerificationResult: json['terminal_verification_result'] as String,
      transactionStateInformation: json['transaction_state_information'] as String,
      // JSON typo: "cardholader_verfication_result"
      cardholderVerificationResult:
      (json['cardholder_verification_result'] ??
          json['cardholader_verfication_result']) as String,
      cryptogramInformationData: json['cryptogram_information_data'] as String,
      applicationCryptogram: json['application_cryptogram'] as String,
      kernelId: json['kernel_id'] as String,
      paymentAccountReference: _nullIfEmpty(json['payment_account_reference'] as String?),
      panSuffix: _nullIfEmpty(json['pan_suffix'] as String?),
      customerReferenceNumber: _nullIfEmpty(json['customer_reference_number'] as String?),
      qrCode: json['qr_code'] as String,
      transactionUuid: json['transaction_uuid'] as String,
      vasData: _nullIfEmpty(json['vas_data'] as String?),
    );
  }

  @override
  String toString() =>
      'ReceiptData(id: $id, merchant: $merchant, cardScheme: $cardScheme, '
          'transactionType: $transactionType, approved: $isApproved, '
          'amountAuthorized: $amountAuthorized, currency: $currency, qr: $qrCode)';
}


class ApprovalCode {
  final String value;
  final LanguageContent label;

  ApprovalCode({
    required this.value,
    required this.label,
  });

  factory ApprovalCode.fromJson(dynamic json) {
    return ApprovalCode(
      value: json['value'],
      label: LanguageContent.fromJson(json['label']),
    );
  }
}

class LabelField<T> {
  final T value;

  LabelField({required this.value});

  factory LabelField.fromJson(dynamic json) {
    return LabelField(
      value: json['value'],
    );
  }

}

class CardScheme {
  final LanguageContent? name;
  final String? id;

  CardScheme({
    required this.name,
    required this.id,
  });

  factory CardScheme.fromJson(dynamic json) {
    return CardScheme(
      name: LanguageContent.fromJson(json['name']),
      id: json['id'],
    );
  }

}

// Define the TransactionType class
class TransactionType {
  final String? id;
  final LanguageContent? name;

  TransactionType({
    required this.id,
    required this.name,
  });

  factory TransactionType.fromJson(dynamic json) {
    return TransactionType(
      id: json['id'],
      name: LanguageContent.fromJson(json['name']),
    );
  }

}
