import 'package:flutter_terminal_sdk/domain/models/util/json_pick.dart';

Map<String, String>? normalizeLocalizationFieldUSA(dynamic raw) {
  if (raw is! Map) return null;
  final payload = Map<String, dynamic>.from(raw);
  final arabic = pickKey(payload, ['arabic', 'ar'])?.toString() ?? '';
  final english = pickKey(payload, ['english', 'en'])?.toString() ?? '';
  if (arabic.isEmpty && english.isEmpty) return null;
  return {'arabic': arabic, 'english': english};
}

Map<String, dynamic>? normalizeReceiptCardSchemeJson(dynamic raw) {
  if (raw is String) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return {
      'id': value,
      'name': {'english': value},
    };
  }

  if (raw is! Map) return null;

  final payload = Map<String, dynamic>.from(raw);
  final id = pickKey(payload, ['id'])?.toString().trim();
  final rawName = pickMap(payload, ['name']);
  String? arabic;
  String? english;
  String? turkish;
  if (rawName != null) {
    arabic = pickKey(rawName, ['arabic'])?.toString().trim();
    english = pickKey(rawName, ['english'])?.toString().trim();
    turkish = pickKey(rawName, ['turkish'])?.toString().trim();
    if (arabic != null && arabic.isEmpty) arabic = null;
    if (english != null && english.isEmpty) english = null;
    if (turkish != null && turkish.isEmpty) turkish = null;
  }

  Map<String, dynamic>? name;
  if (arabic != null || english != null || turkish != null) {
    name = {
      if (arabic != null) 'arabic': arabic,
      if (english != null) 'english': english,
      if (turkish != null) 'turkish': turkish,
    };
  } else if (id != null && id.isNotEmpty) {
    name = {'english': id};
  }

  final resolvedId = (id != null && id.isNotEmpty) ? id : null;
  if (resolvedId == null && name == null) return null;

  return {
    if (resolvedId != null) 'id': resolvedId,
    if (name != null) 'name': name,
  };
}
