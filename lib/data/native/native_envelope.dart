import 'dart:convert';

class NativeEnvelope {
  final String? status;
  final String? message;
  final String? code;
  final String? type;

  final Object? data;

  final Map<String, dynamic>? nativeError;

  final Map<String, dynamic> raw;

  const NativeEnvelope({
    this.status,
    this.message,
    this.code,
    this.type,
    this.data,
    this.nativeError,
    this.raw = const {},
  });

  bool get isSuccess => status?.trim().toLowerCase() == 'success';

  factory NativeEnvelope.from(Object? rawResponse) {
    final decoded = _normalize(rawResponse);

    if (decoded is! Map<String, dynamic>) {
      return NativeEnvelope(data: decoded);
    }

    return NativeEnvelope(
      status: decoded['status'] as String?,
      message: decoded['message'] as String?,
      code: decoded['code']?.toString(),
      type: decoded['type']?.toString(),
      data: decoded.containsKey('data') ? decoded['data'] : decoded,
      nativeError: decoded['nativeError'] is Map
          ? Map<String, dynamic>.from(decoded['nativeError'] as Map)
          : null,
      raw: decoded,
    );
  }

  Map<String, dynamic> asMap() => raw;

  static Object? _normalize(Object? value) {
    try {
      return jsonDecode(jsonEncode(value));
    } catch (_) {
      return value;
    }
  }
}
