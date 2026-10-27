part of 'transaction_response.dart';

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
  final LabelField2<String> amountAuthorized;
  final LabelField2<String> amountOther;
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
  final String cardholderVerificationResult;
  final String cryptogramInformationData;
  final String applicationCryptogram;
  final String kernelId;
  final String? paymentAccountReference;
  final String? panSuffix;
  final String? customerReferenceNumber;
  final String qrCode;
  final String transactionUuid;
  final String? vasData;
  final String? tokenizationID;

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
    this.tokenizationID,
  });

  factory ReceiptData.fromMadaJson(Map<String, dynamic> json) {
    final merchantMap = pickMap(json, ['merchant'])!;
    final cardSchemeMap = pickMap(json, ['card_scheme', 'cardScheme'])!;
    final transactionTypeMap =
        pickMap(json, ['transaction_type', 'transactionType'])!;
    final approvalCodeMap = pickMap(json, ['approval_code', 'approvalCode']);
    final statusMessageMap =
        pickMap(json, ['status_message', 'statusMessage'])!;
    final amountAuthorizedMap =
        pickMap(json, ['amount_authorized', 'amountAuthorized'])!;
    final amountOtherMap = pickMap(json, ['amount_other', 'amountOther'])!;
    final currencyMap = pickMap(json, ['currency'])!;
    final verificationMethodMap =
        pickMap(json, ['verification_method', 'verificationMethod'])!;
    final receiptLineOneMap =
        pickMap(json, ['receipt_line_one', 'receiptLineOne'])!;
    final receiptLineTwoMap =
        pickMap(json, ['receipt_line_two', 'receiptLineTwo'])!;
    final thanksMessageMap =
        pickMap(json, ['thanks_message', 'thanksMessage'])!;
    final saveReceiptMessageMap =
        pickMap(json, ['save_receipt_message', 'saveReceiptMessage'])!;

    return ReceiptData(
      id: pickKey(json, ['id']) as String,
      merchant: mr.Merchant.fromJson(merchantMap),
      cardScheme: CardScheme.fromJson(cardSchemeMap),
      cardSchemeSponsor: pickKey(
        json,
        ['card_scheme_sponsor', 'cardSchemeSponsor'],
      ) as String,
      startDate: pickKey(json, ['start_date', 'startDate']) as String,
      startTime: pickKey(json, ['start_time', 'startTime']) as String,
      endDate: pickKey(json, ['end_date', 'endDate']) as String,
      endTime: pickKey(json, ['end_time', 'endTime']) as String,
      terminalId: pickKey(json, ['tid']) as String,
      systemTraceAuditNumber: pickKey(
        json,
        ['system_trace_audit_number', 'systemTraceAuditNumber'],
      ) as String,
      posSoftwareVersion: pickKey(
        json,
        ['pos_software_version_number', 'posSoftwareVersionNumber'],
      ) as String,
      retrievalReferenceNumber: pickKey(
        json,
        ['retrieval_reference_number', 'retrievalReferenceNumber'],
      ) as String,
      transactionType: TransactionType.fromJson(transactionTypeMap),
      isApproved: pickKey(json, ['is_approved', 'isApproved']) as bool,
      isRefunded: pickKey(json, ['is_refunded', 'isRefunded']) as bool,
      isReversed: pickKey(json, ['is_reversed', 'isReversed']) as bool,
      approvalCode: approvalCodeMap == null
          ? null
          : ApprovalCode.fromJson(approvalCodeMap),
      actionCode: pickKey(json, ['action_code', 'actionCode']) as String,
      statusMessage: CurrencyContent.fromJson(statusMessageMap),
      pan: pickKey(json, ['pan']) as String,
      cardExpiration:
          pickKey(json, ['card_expiration', 'cardExpiration']) as String,
      amountAuthorized: LabelField2<String>.fromJson(amountAuthorizedMap),
      amountOther: LabelField2<String>.fromJson(amountOtherMap),
      currency: CurrencyContent.fromJson(currencyMap),
      verificationMethod: CurrencyContent.fromJson(verificationMethodMap),
      receiptLineOne: CurrencyContent.fromJson(receiptLineOneMap),
      receiptLineTwo: CurrencyContent.fromJson(receiptLineTwoMap),
      thanksMessage: CurrencyContent.fromJson(thanksMessageMap),
      saveReceiptMessage: CurrencyContent.fromJson(saveReceiptMessageMap),
      entryMode: pickKey(json, ['entry_mode', 'entryMode']) as String,
      applicationIdentifier: pickKey(
        json,
        ['application_identifier', 'applicationIdentifier'],
      ) as String,
      terminalVerificationResult: pickKey(
        json,
        ['terminal_verification_result', 'terminalVerificationResult'],
      ) as String,
      transactionStateInformation: pickKey(
        json,
        ['transaction_state_information', 'transactionStateInformation'],
      ) as String,
      cardholderVerificationResult: (pickKey(json, [
            'cardholader_verfication_result',
            'cardholder_verification_result',
            'cardholderVerificationResult',
          ]) ??
          '') as String,
      cryptogramInformationData: pickKey(
        json,
        ['cryptogram_information_data', 'cryptogramInformationData'],
      ) as String,
      applicationCryptogram: pickKey(
        json,
        ['application_cryptogram', 'applicationCryptogram'],
      ) as String,
      kernelId: pickKey(json, ['kernel_id', 'kernelId']) as String,
      paymentAccountReference: _nullIfEmpty(
        pickKey(json, ['payment_account_reference', 'paymentAccountReference'])
            as String?,
      ),
      panSuffix: _nullIfEmpty(
        pickKey(json, ['pan_suffix', 'panSuffix']) as String?,
      ),
      customerReferenceNumber: _nullIfEmpty(
        pickKey(json, ['customer_reference_number', 'customerReferenceNumber'])
            as String?,
      ),
      qrCode: pickKey(json, ['qr_code', 'qrCode']) as String,
      transactionUuid: pickKey(
        json,
        ['transaction_uuid', 'transactionUuid', 'transactionUUID'],
      ) as String,
      vasData: _nullIfEmpty(pickKey(json, ['vas_data', 'vasData']) as String?),
      tokenizationID: _nullIfEmpty(
        pickKey(json, ['tokenization_id', 'tokenizationID', 'tokenizationId'])
            as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchant.toJson(),
      'card_scheme': cardScheme.toJson(),
      'card_scheme_sponsor': cardSchemeSponsor,
      'start_date': startDate,
      'start_time': startTime,
      'end_date': endDate,
      'end_time': endTime,
      'tid': terminalId,
      'system_trace_audit_number': systemTraceAuditNumber,
      'pos_software_version_number': posSoftwareVersion,
      'retrieval_reference_number': retrievalReferenceNumber,
      'transaction_type': transactionType.toJson(),
      'is_approved': isApproved,
      'is_refunded': isRefunded,
      'is_reversed': isReversed,
      'approval_code': approvalCode?.toJson(),
      'action_code': actionCode,
      'status_message': statusMessage.toJson(),
      'pan': pan,
      'card_expiration': cardExpiration,
      'amount_authorized': amountAuthorized.toJson(),
      'amount_other': amountOther.toJson(),
      'currency': currency.toJson(),
      'verification_method': verificationMethod.toJson(),
      'receipt_line_one': receiptLineOne.toJson(),
      'receipt_line_two': receiptLineTwo.toJson(),
      'thanks_message': thanksMessage.toJson(),
      'save_receipt_message': saveReceiptMessage.toJson(),
      'entry_mode': entryMode,
      'application_identifier': applicationIdentifier,
      'terminal_verification_result': terminalVerificationResult,
      'transaction_state_information': transactionStateInformation,
      'cardholader_verfication_result': cardholderVerificationResult,
      'cryptogram_information_data': cryptogramInformationData,
      'application_cryptogram': applicationCryptogram,
      'kernel_id': kernelId,
      'payment_account_reference': paymentAccountReference,
      'pan_suffix': panSuffix,
      'customer_reference_number': customerReferenceNumber,
      'qr_code': qrCode,
      'transaction_uuid': transactionUuid,
      'vas_data': vasData,
      'tokenization_id': tokenizationID,
    };
  }

  Future<Uint8List> toImage({
    int? receiptWidth,
    int? fontSize,
  }) =>
      renderReceiptImage(
        toJson(),
        receiptWidth: receiptWidth,
        fontSize: fontSize,
      );

  @override
  String toString() =>
      'ReceiptData(id: $id, merchant: $merchant, cardScheme: $cardScheme, '
      'transactionType: $transactionType, approved: $isApproved, '
      'amountAuthorized: $amountAuthorized, currency: $currency, qr: $qrCode)';
}
