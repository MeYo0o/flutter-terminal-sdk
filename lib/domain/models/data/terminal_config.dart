import 'dto/language_content.dart';

class TerminalSchemeConfig {
  final String code;
  final List<String> allowedTransactionTypes;

  const TerminalSchemeConfig({
    required this.code,
    required this.allowedTransactionTypes,
  });

  factory TerminalSchemeConfig.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    final types = map['allowedTransactionTypes'] as List<dynamic>? ?? const [];
    return TerminalSchemeConfig(
      code: map['code'] as String? ?? '',
      allowedTransactionTypes: types.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'allowedTransactionTypes': allowedTransactionTypes,
      };
}

class TerminalConfigTerminal {
  final String id;
  final String tid;
  final String? name;
  final String? currencyCode;

  const TerminalConfigTerminal({
    required this.id,
    required this.tid,
    this.name,
    this.currencyCode,
  });

  factory TerminalConfigTerminal.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    return TerminalConfigTerminal(
      id: map['id']?.toString() ?? '',
      tid: map['tid']?.toString() ?? '',
      name: map['name']?.toString(),
      currencyCode: map['currencyCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tid': tid,
        'name': name,
        'currencyCode': currencyCode,
      };
}

class TerminalConfigMerchantFlags {
  final bool? invoiceMode;
  final num? cashDiscount;

  const TerminalConfigMerchantFlags({this.invoiceMode, this.cashDiscount});

  factory TerminalConfigMerchantFlags.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    return TerminalConfigMerchantFlags(
      invoiceMode: map['invoiceMode'] as bool?,
      cashDiscount: map['cashDiscount'] as num?,
    );
  }

  Map<String, dynamic> toJson() => {
        'invoiceMode': invoiceMode,
        'cashDiscount': cashDiscount,
      };
}

class TerminalConfigMerchant {
  final LanguageContent? name;
  final LanguageContent? address;
  final num? surchargeAmount;
  final num? taxPercentage;
  final TerminalConfigMerchantFlags? configuration;

  const TerminalConfigMerchant({
    this.name,
    this.address,
    this.surchargeAmount,
    this.taxPercentage,
    this.configuration,
  });

  factory TerminalConfigMerchant.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    return TerminalConfigMerchant(
      name: map['name'] != null ? LanguageContent.fromJson(map['name']) : null,
      address: map['address'] != null
          ? LanguageContent.fromJson(map['address'])
          : null,
      surchargeAmount: map['surchargeAmount'] as num?,
      taxPercentage: map['taxPercentage'] as num?,
      configuration: map['configuration'] != null
          ? TerminalConfigMerchantFlags.fromJson(map['configuration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name?.toJson(),
        'address': address?.toJson(),
        'surchargeAmount': surchargeAmount,
        'taxPercentage': taxPercentage,
        'configuration': configuration?.toJson(),
      };
}

class TerminalConfig {
  final int currencyNumericCode;
  final int currencyDefaultFractionDigits;
  final List<TerminalSchemeConfig> schemes;

  final TerminalConfigTerminal? terminal;
  final TerminalConfigMerchant? merchant;
  final Map<String, bool>? supportedOperations;
  final Map<String, dynamic>? networkConfiguration;

  const TerminalConfig({
    required this.currencyNumericCode,
    required this.currencyDefaultFractionDigits,
    required this.schemes,
    this.terminal,
    this.merchant,
    this.supportedOperations,
    this.networkConfiguration,
  });

  factory TerminalConfig.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    final schemesRaw = map['schemes'] as List<dynamic>? ?? const [];
    final supportedRaw = map['supportedOperations'];
    final networkRaw = map['networkConfiguration'];
    return TerminalConfig(
      currencyNumericCode: _asInt(map['currencyNumericCode']),
      currencyDefaultFractionDigits:
          _asInt(map['currencyDefaultFractionDigits']),
      schemes: schemesRaw.map((e) => TerminalSchemeConfig.fromJson(e)).toList(),
      terminal: map['terminal'] != null
          ? TerminalConfigTerminal.fromJson(map['terminal'])
          : null,
      merchant: map['merchant'] != null
          ? TerminalConfigMerchant.fromJson(map['merchant'])
          : null,
      supportedOperations: supportedRaw is Map
          ? supportedRaw
              .map((key, value) => MapEntry(key.toString(), value == true))
          : null,
      networkConfiguration:
          networkRaw is Map ? Map<String, dynamic>.from(networkRaw) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'currencyNumericCode': currencyNumericCode,
        'currencyDefaultFractionDigits': currencyDefaultFractionDigits,
        'schemes': schemes.map((s) => s.toJson()).toList(),
        if (terminal != null) 'terminal': terminal!.toJson(),
        if (merchant != null) 'merchant': merchant!.toJson(),
        if (supportedOperations != null)
          'supportedOperations': supportedOperations,
        if (networkConfiguration != null)
          'networkConfiguration': networkConfiguration,
      };

  @override
  String toString() =>
      'TerminalConfig(currencyNumericCode: $currencyNumericCode, '
      'currencyDefaultFractionDigits: $currencyDefaultFractionDigits, '
      'schemes: $schemes, terminal: $terminal, merchant: $merchant)';
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
