import 'package:flutter_terminal_sdk/domain/models/util/json_pick.dart';

class AuthenticatorResponse {
  final bool requiresOtp;
  final String? type;
  final String? value;

  const AuthenticatorResponse({
    required this.requiresOtp,
    required this.type,
    required this.value,
  });

  factory AuthenticatorResponse.fromJson(Map<String, dynamic> json) {
    final typeValue = pickKey(json, ['type']);
    final valueValue = pickKey(json, ['value']);
    return AuthenticatorResponse(
      requiresOtp: toBoolSafe(pickKey(json, ['requiresOtp', 'requires_otp'])),
      type: typeValue == null ? null : toStringSafe(typeValue),
      value: valueValue == null ? null : toStringSafe(valueValue),
    );
  }

  Map<String, dynamic> toJson() => {
        'requiresOtp': requiresOtp,
        'type': type,
        'value': value,
      };
}
