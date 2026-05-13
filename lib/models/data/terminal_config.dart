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

class TerminalConfig {
  final int currencyNumericCode;
  final int currencyDefaultFractionDigits;
  final List<TerminalSchemeConfig> schemes;

  const TerminalConfig({
    required this.currencyNumericCode,
    required this.currencyDefaultFractionDigits,
    required this.schemes,
  });

  factory TerminalConfig.fromJson(dynamic json) {
    final map = Map<String, dynamic>.from(json as Map);
    final schemesRaw = map['schemes'] as List<dynamic>? ?? const [];
    return TerminalConfig(
      currencyNumericCode: _asInt(map['currencyNumericCode']),
      currencyDefaultFractionDigits:
          _asInt(map['currencyDefaultFractionDigits']),
      schemes: schemesRaw
          .map((e) => TerminalSchemeConfig.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'currencyNumericCode': currencyNumericCode,
        'currencyDefaultFractionDigits': currencyDefaultFractionDigits,
        'schemes': schemes.map((s) => s.toJson()).toList(),
      };

  @override
  String toString() =>
      'TerminalConfig(currencyNumericCode: $currencyNumericCode, '
      'currencyDefaultFractionDigits: $currencyDefaultFractionDigits, '
      'schemes: $schemes)';
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
