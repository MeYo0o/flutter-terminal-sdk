import 'currency_content.dart';
import '../../util/json_pick.dart';

class TransactionResponseUSA {
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

  TransactionResponseUSA({
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

  factory TransactionResponseUSA.fromJson(dynamic json) {
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

    return TransactionResponseUSA(
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
      card: json['card'] != null ? Map<String, dynamic>.from(json['card']) : {},
      events: eventItems,
      amountOther: json['amountOther'],
    );
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
}

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

class AuthorizeReceipt {
  final String rrn;
  final String tid;

  final CardInfo card;
  final List<MetaEntry> meta;

  final String stan;
  final String token;
  final String? tokenizationID;

  final String amount;
  final String? tips;
  final String? totalAmount;
  final String? totalFees;

  final String endAt;
  final String startAt;

  final String status;
  final String version;

  final Currency currency;
  final Merchant merchant;

  final String authCode;
  final String actionCode;

  final String receiptType;
  final String taxPercentage;
  final String surchargeAmount;

  final String transactionUuid;

  final AmountOnly amountAuthorized;

  final List<String> supportedLanguages;

  final String? qrCode;

  const AuthorizeReceipt({
    required this.rrn,
    required this.tid,
    required this.card,
    required this.meta,
    required this.stan,
    required this.token,
    this.tokenizationID,
    required this.amount,
    this.tips,
    this.totalAmount,
    required this.endAt,
    required this.status,
    required this.version,
    required this.currency,
    required this.merchant,
    required this.startAt,
    required this.authCode,
    required this.totalFees,
    required this.actionCode,
    required this.receiptType,
    required this.taxPercentage,
    required this.surchargeAmount,
    required this.transactionUuid,
    required this.amountAuthorized,
    required this.supportedLanguages,
    this.qrCode,
  });

  factory AuthorizeReceipt.fromJson(Map<String, dynamic> json) {
    final cardMap = pickMap(json, ['card'])!;
    final currencyMap = pickMap(json, ['currency'])!;
    final merchantMap = pickMap(json, ['merchant'])!;
    final amountAuthorizedMap =
        pickMap(json, ['amount_authorized', 'amountAuthorized'])!;
    final supportedLanguages = pickKey(
      json,
      ['supportedLanguages', 'supported_languages'],
    );

    return AuthorizeReceipt(
      rrn: pickKey(json, ['rrn']) as String,
      tid: pickKey(json, ['tid']) as String,
      card: CardInfo.fromJson(cardMap),
      meta: (pickKey(json, ['meta']) as List<dynamic>? ?? const [])
          .map((e) => MetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      stan: pickKey(json, ['stan']) as String,
      token: pickKey(json, ['token']) as String,
      tokenizationID: pickKey(
        json,
        ['tokenization_id', 'tokenizationID', 'tokenizationId'],
      ) as String?,
      amount: pickKey(json, ['amount']) as String,
      tips: pickKey(json, ['tips']) as String?,
      totalAmount: pickKey(json, ['total_amount', 'totalAmount']) as String?,
      totalFees: pickKey(json, ['total_fees', 'totalFees']) as String,
      endAt: pickKey(json, ['end_at', 'endAt']) as String,
      startAt: pickKey(json, ['start_at', 'startAt']) as String,
      status: pickKey(json, ['status']) as String,
      version: pickKey(json, ['version']) as String,
      currency: Currency.fromJson(currencyMap),
      merchant: Merchant.fromJson(merchantMap),
      authCode: pickKey(json, ['auth_code', 'authCode']) as String,
      actionCode: pickKey(json, ['action_code', 'actionCode']) as String,
      receiptType: pickKey(json, ['receipt_type', 'receiptType']) as String,
      taxPercentage:
          pickKey(json, ['tax_percentage', 'taxPercentage']) as String,
      surchargeAmount:
          pickKey(json, ['surcharge_amount', 'surchargeAmount']) as String,
      transactionUuid: pickKey(
        json,
        ['transaction_uuid', 'transactionUuid', 'transactionUUID'],
      ) as String,
      amountAuthorized: AmountOnly.fromJson(amountAuthorizedMap),
      supportedLanguages: (supportedLanguages as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(growable: false),
      qrCode: pickKey(json, ['qr_code', 'qrCode']) as String?,
    );
  }

  @override
  String toString() {
    return 'AuthorizeReceipt(rrn: $rrn, tid: $tid, card: $card, meta: $meta, stan: $stan, token: $token, tokenizationID: $tokenizationID, amount: $amount, tips: $tips, totalAmount: $totalAmount, totalFees: $totalFees, endAt: $endAt, status: $status, version: $version, currency: $currency, merchant: $merchant, startAt: $startAt, authCode: $authCode, actionCode: $actionCode, receiptType: $receiptType, taxPercentage: $taxPercentage, surchargeAmount: $surchargeAmount, transactionUuid: $transactionUuid, amountAuthorized: $amountAuthorized, supportedLanguages: $supportedLanguages, qrCode: $qrCode)';
  }
}

class CardInfo {
  final String? exp;
  final String? pan;
  final String? brandCode;
  final String? panSuffix;

  const CardInfo({
    required this.exp,
    required this.pan,
    required this.brandCode,
    required this.panSuffix,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      exp: pickKey(json, ['exp']),
      pan: pickKey(json, ['pan']),
      brandCode: pickKey(json, ['brand_code', 'brandCode']),
      panSuffix: pickKey(json, ['pan_suffix', 'panSuffix']),
    );
  }
}

class MetaEntry {
  final String? key;
  final String? value;

  const MetaEntry({required this.key, required this.value});

  factory MetaEntry.fromJson(Map<String, dynamic> json) {
    return MetaEntry(
      key: json['key'],
      value: json['value'],
    );
  }
}

class AmountOnly {
  final String? value;

  const AmountOnly({required this.value});

  factory AmountOnly.fromJson(Map<String, dynamic> json) {
    return AmountOnly(
      value: json['value'],
    );
  }
}

class LocalizedText {
  final String? ar;
  final String? en;

  const LocalizedText({required this.ar, required this.en});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar'],
      en: json['en'],
    );
  }
}

class Bank {
  final String? id;
  final LocalizedText? name;

  const Bank({required this.id, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      name: json['name'] != null ? LocalizedText.fromJson(json['name']) : null,
    );
  }
}

class Merchant {
  final String id;
  final BankInfo? bank;
  final Map<String, dynamic>? name;
  final Map<String, dynamic>? address;

  const Merchant({
    required this.id,
    this.bank,
    this.name,
    this.address,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String,
      bank: json['bank'] != null
          ? BankInfo.fromJson(json['bank'] as Map<String, dynamic>)
          : null,
      name: json['name'] as Map<String, dynamic>?,
      address: json['address'] as Map<String, dynamic>?,
    );
  }
}

class BankInfo {
  final String id;
  final LocalizedName name;

  const BankInfo({required this.id, required this.name});

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      id: json['id'] as String,
      name: LocalizedName.fromJson(json['name'] as Map<String, dynamic>),
    );
  }
}

class LocalizedName {
  final String? ar;
  final String? en;

  const LocalizedName({this.ar, this.en});

  factory LocalizedName.fromJson(Map<String, dynamic> json) {
    return LocalizedName(
      ar: json['ar'] as String?,
      en: json['en'] as String?,
    );
  }
}

class Currency {
  final String? english;
  final String? arabic;

  const Currency({this.english, this.arabic});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      english: json['english'] as String?,
      arabic: json['arabic'] as String?,
    );
  }
}
