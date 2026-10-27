import 'package:flutter_terminal_sdk/domain/models/data/dto/currency_content.dart';
import 'package:flutter_terminal_sdk/domain/models/util/json_pick.dart';

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

  ReceiptDataTurkey? getBKMReceipt() {
    if (events == null || events!.isEmpty) return null;
    final parsed = parseReceiptPayload(events!.first.receipt?.data);
    if (parsed == null) return null;
    try {
      final type = pickKey(parsed, ['type'])?.toString().toUpperCase();
      if (type != 'BKM') return null;
      final txUuid = pickKey(
        parsed,
        ['transaction_uuid', 'transactionUuid', 'transactionUUID'],
      );
      if (txUuid is! String || txUuid.trim().isEmpty) return null;
      return ReceiptDataTurkey.fromJson(parsed);
    } catch (_) {
      return null;
    }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'performance': performance,
      'cancelReason': cancelReason,
      'status': status,
      'currency': currency,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'referenceId': referenceId,
      'orderId': orderId,
      'pinRequired': pinRequired,
      'card': card,
      'events': events,
      'amountOther': amountOther,
    };
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'receipt': receipt,
      'rrn': rrn,
      'status': status,
    };
  }
}

class Receipt {
  final String? standard;
  final String? id;
  final dynamic data;

  Receipt({
    required this.standard,
    required this.id,
    required this.data,
  });

  ReceiptDataTurkey? getReceiptData() {
    final parsed = parseReceiptPayload(data);
    if (parsed == null) return null;
    try {
      return ReceiptDataTurkey.fromJson(parsed);
    } catch (_) {
      return null;
    }
  }

  factory Receipt.fromJson(dynamic json) {
    return Receipt(
      standard: json['standard'] as String?,
      id: json['id'] as String?,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'standard': standard,
      'id': id,
      'data': data,
    };
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
  final String? replyMessage;
  final String? replyMessageExplanation;

  final String? installmentAmount;
  final int? installmentsCount;
  final String? installmentCalculation;

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
    this.replyMessage,
    this.replyMessageExplanation,
    this.installmentAmount,
    this.installmentsCount,
    this.installmentCalculation,
  });

  factory ReceiptDataTurkey.fromJson(Map<String, dynamic> json) {
    final pinUsedMap = pickMap(json, ['pin_used', 'pinUsed']);
    final statusMessageMap = pickMap(json, ['status_message', 'statusMessage']);
    final transactionTypeMap =
        pickMap(json, ['transaction_type', 'transactionType']);
    final amountAuthorizedMap =
        pickMap(json, ['amount_authorized', 'amountAuthorized']);
    final actionCodeMessageMap =
        pickMap(json, ['action_code_message', 'actionCodeMessage']);
    final transactionDetailsMap =
        pickMap(json, ['transaction_details', 'transactionDetails']);
    final merchantMap = pickMap(json, ['merchant']);
    final currencyMap = pickMap(json, ['currency']);

    return ReceiptDataTurkey(
      id: pickKey(json, ['id']) as String?,
      pan: pickKey(json, ['pan']) as String?,
      tid: pickKey(json, ['tid']) as String?,
      type: pickKey(json, ['type']) as String?,
      date: pickKey(json, ['date']) as String?,
      time: pickKey(json, ['time']) as String?,
      cardType: pickKey(json, ['card_type', 'cardType']) as String?,
      currency:
          currencyMap != null ? CurrencyContent.fromJson(currencyMap) : null,
      merchant: merchantMap != null ? Merchant.fromJson(merchantMap) : null,
      pinUsed: pinUsedMap != null ? LocalizedText.fromJson(pinUsedMap) : null,
      panSuffix: pickKey(json, ['pan_suffix', 'panSuffix']) as String?,
      acquirerId: pickKey(json, ['acquirer_id', 'acquirerId']) as String?,
      actionCode: pickKey(json, ['action_code', 'actionCode']) as String?,
      cardScheme: pickKey(json, ['card_scheme', 'cardScheme']) as String?,
      cardDomain: pickKey(json, ['card_domain', 'cardDomain']) as String?,
      isApproved: pickKey(json, ['is_approved', 'isApproved']) as bool?,
      batchNumber: pickKey(json, ['batch_number', 'batchNumber']) as String?,
      acquirerName: pickKey(json, ['acquirer_name', 'acquirerName']) as String?,
      approvalCode: pickKey(json, ['approval_code', 'approvalCode']) as String?,
      serialNumber: pickKey(json, ['serial_number', 'serialNumber']) as String?,
      bankReference:
          pickKey(json, ['bank_reference', 'bankReference']) as String?,
      deviceDetails:
          pickKey(json, ['device_details', 'deviceDetails']) as String?,
      statusMessage: statusMessageMap != null
          ? LocalizedText.fromJson(statusMessageMap)
          : null,
      cardExpiration:
          pickKey(json, ['card_expiration', 'cardExpiration']) as String?,
      transactionCode:
          pickKey(json, ['transaction_code', 'transactionCode']) as String?,
      transactionType: transactionTypeMap != null
          ? TransactionType.fromJson(transactionTypeMap)
          : null,
      transactionUuid: pickKey(
        json,
        ['transaction_uuid', 'transactionUuid', 'transactionUUID'],
      ) as String?,
      amountAuthorized: amountAuthorizedMap != null
          ? AmountAuthorized.fromJson(amountAuthorizedMap)
          : null,
      installmentAmount:
          pickKey(json, ['installment_amount', 'installmentAmount']) as String?,
      installmentsCount:
          (pickKey(json, ['installments_count', 'installmentsCount']) as num?)
              ?.toInt(),
      installmentCalculation: pickKey(
        json,
        ['installment_calculation', 'installmentCalculation'],
      ) as String?,
      transactionNumber:
          pickKey(json, ['transaction_number', 'transactionNumber']) as String?,
      actionCodeMessage: actionCodeMessageMap != null
          ? LocalizedText.fromJson(actionCodeMessageMap)
          : null,
      cardSchemeSponsor: pickKey(
        json,
        ['card_scheme_sponsor', 'cardSchemeSponsor'],
      ) as String?,
      transactionDetails: transactionDetailsMap != null
          ? LocalizedText.fromJson(transactionDetailsMap)
          : null,
      applicationCryptogram: pickKey(
        json,
        ['application_cryptogram', 'applicationCryptogram'],
      ) as String?,
      applicationIdentifier: pickKey(
        json,
        ['application_identifier', 'applicationIdentifier'],
      ) as String?,
      paymentAccountReference: pickKey(
        json,
        ['payment_account_reference', 'paymentAccountReference'],
      ) as String?,
      systemTraceAuditNumber: pickKey(
        json,
        ['system_trace_audit_number', 'systemTraceAuditNumber'],
      ) as String?,
      retrievalReferenceNumber: pickKey(
        json,
        ['retrieval_reference_number', 'retrievalReferenceNumber'],
      ) as String?,
      cryptogramInformationData: pickKey(
        json,
        ['cryptogram_information_data', 'cryptogramInformationData'],
      ) as String?,
      posSoftwareVersionNumber: pickKey(
        json,
        ['pos_software_version_number', 'posSoftwareVersionNumber'],
      ) as String?,
      qrCode: pickKey(json, ['qr_code', 'qrCode']) as String?,
      transactionStateInformation: pickKey(
        json,
        ['transaction_state_information', 'transactionStateInformation'],
      ) as String?,
      cardholderVerificationResult: pickKey(
        json,
        ['cardholder_verification_result', 'cardholderVerificationResult'],
      ) as String?,
      replyMessage: pickKey(json, ['reply_message', 'replyMessage']) as String?,
      replyMessageExplanation: pickKey(
        json,
        ['reply_message_explanation', 'replyMessageExplanation'],
      ) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pan': pan,
      'tid': tid,
      'type': type,
      'date': date,
      'time': time,
      'card_type': cardType,
      'currency': currency,
      'merchant': merchant,
      'pin_used': pinUsed,
      'pan_suffix': panSuffix,
      'acquirer_id': acquirerId,
      'action_code': actionCode,
      'card_scheme': cardScheme,
      'card_domain': cardDomain,
      'is_approved': isApproved,
      'batch_number': batchNumber,
      'acquirer_name': acquirerName,
      'approval_code': approvalCode,
      'serial_number': serialNumber,
      'bank_reference': bankReference,
      'device_details': deviceDetails,
      'status_message': statusMessage,
      'card_expiration': cardExpiration,
      'transaction_code': transactionCode,
      'transaction_type': transactionType,
      'transaction_uuid': transactionUuid,
      'amount_authorized': amountAuthorized,
      'transaction_number': transactionNumber,
      'action_code_message': actionCodeMessage,
      'card_scheme_sponsor': cardSchemeSponsor,
      'transaction_details': transactionDetails,
      'application_cryptogram': applicationCryptogram,
      'application_identifier': applicationIdentifier,
      'payment_account_reference': paymentAccountReference,
      'system_trace_audit_number': systemTraceAuditNumber,
      'retrieval_reference_number': retrievalReferenceNumber,
      'cryptogram_information_data': cryptogramInformationData,
      'pos_software_version_number': posSoftwareVersionNumber,
      'qr_code': qrCode,
      'transaction_state_information': transactionStateInformation,
      'cardholder_verification_result': cardholderVerificationResult,
      'reply_message': replyMessage,
      'reply_message_explanation': replyMessageExplanation,
      'installment_amount': installmentAmount,
      'installments_count': installmentsCount,
      'installment_calculation': installmentCalculation,
    };
  }

  @override
  String toString() {
    return 'ReceiptDataTurkey(id: $id, pan: $pan, tid: $tid, type: $type, date: $date, time: $time, cardType: $cardType, currency: $currency, merchant: $merchant, pinUsed: $pinUsed, panSuffix: $panSuffix, acquirerId: $acquirerId, actionCode: $actionCode, cardScheme: $cardScheme, cardDomain: $cardDomain, isApproved: $isApproved, batchNumber: $batchNumber, acquirerName: $acquirerName, approvalCode: $approvalCode, serialNumber: $serialNumber, bankReference: $bankReference, deviceDetails: $deviceDetails, statusMessage: $statusMessage, cardExpiration: $cardExpiration, transactionCode: $transactionCode, transactionType: $transactionType, transactionUuid: $transactionUuid, amountAuthorized: $amountAuthorized, transactionNumber: $transactionNumber, actionCodeMessage: $actionCodeMessage, cardSchemeSponsor: $cardSchemeSponsor, transactionDetails: $transactionDetails, applicationCryptogram: $applicationCryptogram, applicationIdentifier: $applicationIdentifier, paymentAccountReference: $paymentAccountReference, systemTraceAuditNumber: $systemTraceAuditNumber, retrievalReferenceNumber: $retrievalReferenceNumber, cryptogramInformationData: $cryptogramInformationData, posSoftwareVersionNumber: $posSoftwareVersionNumber, qrCode: $qrCode, transactionStateInformation: $transactionStateInformation, cardholderVerificationResult: $cardholderVerificationResult , replyMessage: $replyMessage, replyMessageExplanation: $replyMessageExplanation, installmentAmount: $installmentAmount, installmentsCount: $installmentsCount, installmentCalculation: $installmentCalculation)';
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'english': english,
      'turkish': turkish,
    };
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}
