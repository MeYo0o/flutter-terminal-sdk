
import 'currency_content.dart';

// Define the main response object
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
        // Ensure each item is a map
        // if (item is Map<String, dynamic>) {
        return PerformanceDto.fromJson(item);
        // } else {
        //   print('Item is not a Map<String, dynamic>');
        //   print("item $item");
        //   print("item ${item.toString()}");
        //   print("item ${item["timeStamp"]}");
        //   print("item ${item["type"]}");
        //   // Handle case when item is not a Map<String, dynamic>
        //   return PerformanceDto(type: '', timeStamp: 0); // Placeholder or handle error
        // }
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

// authorize_receipt.dart

class AuthorizeReceipt {
  final String rrn;
  final String tid;
  final CardInfo card;
  final List<MetaEntry> meta;
  final String stan;
  final String token;
  final String amount;
  final String endAt; // keep as ISO string
  final String status;
  final String version;
  final Currency currency;
  final Merchant merchant;
  final String startAt; // keep as ISO string
  final String authCode;
  final String totalFees;
  final String actionCode;
  final String receiptType;
  final String taxPercentage;
  final String surchargeAmount;
  final String transactionUuid;
  final AmountOnly amountAuthorized;
  final List<String> supportedLanguages;

  const AuthorizeReceipt({
    required this.rrn,
    required this.tid,
    required this.card,
    required this.meta,
    required this.stan,
    required this.token,
    required this.amount,
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
  });

  factory AuthorizeReceipt.fromJson(Map<String, dynamic> json) {
    return AuthorizeReceipt(
      rrn: json['rrn'] as String,
      tid: json['tid'] as String,
      card: CardInfo.fromJson(json['card'] as Map<String, dynamic>),
      meta: (json['meta'] as List<dynamic>? ?? const [])
          .map((e) => MetaEntry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      stan: json['stan'] as String,
      token: json['token'] as String,
      amount: json['amount'] as String,
      endAt: json['end_at'] as String,
      status: json['status'] as String,
      version: json['version'] as String,
      currency: Currency.fromJson(json['currency'] as Map<String, dynamic>),
      merchant: Merchant.fromJson(json['merchant'] as Map<String, dynamic>),
      startAt: json['start_at'] as String,
      authCode: json['auth_code'] as String,
      totalFees: json['total_fees'] as String,
      actionCode: json['action_code'] as String,
      receiptType: json['receipt_type'] as String,
      taxPercentage: json['tax_percentage'] as String,
      surchargeAmount: json['surcharge_amount'] as String,
      transactionUuid: json['transaction_uuid'] as String,
      amountAuthorized:
      AmountOnly.fromJson(json['amount_authorized'] as Map<String, dynamic>),
      supportedLanguages: (json['supported_languages'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(growable: false),
    );
  }
}

class CardInfo {
  final String exp;
  final String pan;
  final String brandCode;
  final String panSuffix;

  const CardInfo({
    required this.exp,
    required this.pan,
    required this.brandCode,
    required this.panSuffix,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      exp: json['exp'] as String,
      pan: json['pan'] as String,
      brandCode: json['brand_code'] as String,
      panSuffix: json['pan_suffix'] as String,
    );
  }
}

class MetaEntry {
  final String key;
  final String value;

  const MetaEntry({required this.key, required this.value});

  factory MetaEntry.fromJson(Map<String, dynamic> json) {
    return MetaEntry(
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }
}

class AmountOnly {
  final String value;

  const AmountOnly({required this.value});

  factory AmountOnly.fromJson(Map<String, dynamic> json) {
    return AmountOnly(
      value: json['value'] as String,
    );
  }
}

class Currency {
  final String arabic;
  final String english;

  const Currency({required this.arabic, required this.english});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      arabic: json['arabic'] as String,
      english: json['english'] as String,
    );
  }
}

class LocalizedText {
  final String ar;
  final String en;

  const LocalizedText({required this.ar, required this.en});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar'] as String,
      en: json['en'] as String,
    );
  }
}

class Bank {
  final String id;
  final LocalizedText name;

  const Bank({required this.id, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] as String,
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    );
  }
}

class Merchant {
  final String id;
  final String mcc;
  final Bank bank;
  final LocalizedText name;
  final String phone;
  final LocalizedText address;

  const Merchant({
    required this.id,
    required this.mcc,
    required this.bank,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'] as String,
      mcc: json['mcc'] as String,
      bank: Bank.fromJson(json['bank'] as Map<String, dynamic>),
      name: LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
      phone: json['phone'] as String,
      address: LocalizedText.fromJson(json['address'] as Map<String, dynamic>),
    );
  }
}

