/// Shared terminal-config wire-shapes (parity with rn-terminal-sdk
/// `data/dto/shared/terminalConfigDto`).
library;

class LocalizationFieldDto {
  final String? english;
  final String? arabic;
  final String? turkish;

  const LocalizationFieldDto({this.english, this.arabic, this.turkish});

  factory LocalizationFieldDto.fromMap(Map<String, dynamic> map) {
    return LocalizationFieldDto(
      english: map['english'] as String?,
      arabic: map['arabic'] as String?,
      turkish: map['turkish'] as String?,
    );
  }
}

class TerminalConfigSchemeDto {
  final String? code;
  final List<String>? allowedTransactionTypes;

  const TerminalConfigSchemeDto({this.code, this.allowedTransactionTypes});

  factory TerminalConfigSchemeDto.fromMap(Map<String, dynamic> map) {
    return TerminalConfigSchemeDto(
      code: map['code'] as String?,
      allowedTransactionTypes: (map['allowedTransactionTypes'] as List?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class TerminalConfigTerminalDto {
  final String? id;
  final String? tid;
  final String? name;
  final String? currencyCode;

  const TerminalConfigTerminalDto({
    this.id,
    this.tid,
    this.name,
    this.currencyCode,
  });

  factory TerminalConfigTerminalDto.fromMap(Map<String, dynamic> map) {
    return TerminalConfigTerminalDto(
      id: map['id'] as String?,
      tid: map['tid'] as String?,
      name: map['name'] as String?,
      currencyCode: map['currencyCode'] as String?,
    );
  }
}

class TerminalConfigMerchantFlagsDto {
  final bool? invoiceMode;
  final num? cashDiscount;

  const TerminalConfigMerchantFlagsDto({this.invoiceMode, this.cashDiscount});

  factory TerminalConfigMerchantFlagsDto.fromMap(Map<String, dynamic> map) {
    return TerminalConfigMerchantFlagsDto(
      invoiceMode: map['invoiceMode'] as bool?,
      cashDiscount: map['cashDiscount'] as num?,
    );
  }
}

class TerminalConfigMerchantDto {
  final LocalizationFieldDto? name;
  final LocalizationFieldDto? address;
  final num? surchargeAmount;
  final num? taxPercentage;
  final TerminalConfigMerchantFlagsDto? configuration;

  const TerminalConfigMerchantDto({
    this.name,
    this.address,
    this.surchargeAmount,
    this.taxPercentage,
    this.configuration,
  });

  factory TerminalConfigMerchantDto.fromMap(Map<String, dynamic> map) {
    return TerminalConfigMerchantDto(
      name: map['name'] == null
          ? null
          : LocalizationFieldDto.fromMap(
              Map<String, dynamic>.from(map['name'] as Map)),
      address: map['address'] == null
          ? null
          : LocalizationFieldDto.fromMap(
              Map<String, dynamic>.from(map['address'] as Map)),
      surchargeAmount: map['surchargeAmount'] as num?,
      taxPercentage: map['taxPercentage'] as num?,
      configuration: map['configuration'] == null
          ? null
          : TerminalConfigMerchantFlagsDto.fromMap(
              Map<String, dynamic>.from(map['configuration'] as Map)),
    );
  }
}

class TerminalConfigResponseDto {
  final num? currencyNumericCode;
  final List<TerminalConfigSchemeDto>? schemes;
  final num? currencyDefaultFractionDigits;
  final TerminalConfigTerminalDto? terminal;
  final TerminalConfigMerchantDto? merchant;
  final Map<String, bool>? supportedOperations;
  final Map<String, dynamic>? networkConfiguration;

  const TerminalConfigResponseDto({
    this.currencyNumericCode,
    this.schemes,
    this.currencyDefaultFractionDigits,
    this.terminal,
    this.merchant,
    this.supportedOperations,
    this.networkConfiguration,
  });

  factory TerminalConfigResponseDto.fromMap(Map<String, dynamic> map) {
    return TerminalConfigResponseDto(
      currencyNumericCode: map['currencyNumericCode'] as num?,
      schemes: (map['schemes'] as List?)
          ?.map((e) => TerminalConfigSchemeDto.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      currencyDefaultFractionDigits:
          map['currencyDefaultFractionDigits'] as num?,
      terminal: map['terminal'] == null
          ? null
          : TerminalConfigTerminalDto.fromMap(
              Map<String, dynamic>.from(map['terminal'] as Map)),
      merchant: map['merchant'] == null
          ? null
          : TerminalConfigMerchantDto.fromMap(
              Map<String, dynamic>.from(map['merchant'] as Map)),
      supportedOperations: map['supportedOperations'] == null
          ? null
          : Map<String, bool>.from(map['supportedOperations'] as Map),
      networkConfiguration: map['networkConfiguration'] == null
          ? null
          : Map<String, dynamic>.from(map['networkConfiguration'] as Map),
    );
  }
}
