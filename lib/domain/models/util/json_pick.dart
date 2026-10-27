import 'dart:convert';

dynamic pickKey(Map json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value;
    }
  }
  return null;
}

Map<String, dynamic>? pickMap(Map json, List<String> keys) {
  final value = pickKey(json, keys);
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String toStringSafe(dynamic value, [String fallback = '']) {
  if (value is String) return value;
  if (value == null) return fallback;
  return value.toString();
}

double toDoubleSafe(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}

num toNumSafe(dynamic value, [num fallback = 0]) {
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}

bool toBoolSafe(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

Map<String, dynamic>? parseReceiptPayload(dynamic data) {
  if (data == null) return null;
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  if (data is String) {
    final trimmed = data.trim();
    if (trimmed.isEmpty) return null;
    final decoded = jsonDecode(trimmed);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  }
  return null;
}
