import 'dart:io' show Platform;

class TerminalMessageErrorInfo {
  const TerminalMessageErrorInfo({
    this.type,
    this.codeText,
    this.statusCode,
    this.terminalPausedSeconds,
    this.level,
    this.source,
    this.error,
    this.solution,
  });

  final int? type;
  final String? codeText;
  final int? statusCode;
  final int? terminalPausedSeconds;
  final String? level;
  final String? source;
  final Map<String, dynamic>? error;
  final Map<String, dynamic>? solution;

  static TerminalMessageErrorInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return TerminalMessageErrorInfo(
      type: _asInt(map['type']),
      codeText: _trimNonEmpty(map['code_text']),
      statusCode: _asInt(map['statusCode']),
      terminalPausedSeconds: _asInt(map['terminalPausedSeconds']),
      level: _trimNonEmpty(map['level']),
      source: _trimNonEmpty(map['source']),
      error: _asMap(map['error']),
      solution: _asMap(map['solution']),
    );
  }
}

class NearpayNativeError {
  final Map<String, dynamic> params;

  const NearpayNativeError(this.params);

  String? get type => _asString(params['type']);

  String? get message => _asString(params['message']);

  String? get description => _asString(params['description']);

  String? get technicalMessage => _asString(params['technicalMessage']);

  Object? get detail => params['detail'];

  Object? get displayError => params['displayError'];

  Map<String, dynamic>? get localizedMessage {
    final value = _asMap(params['localizedMessage']);
    if (value == null) return null;
    final out = <String, dynamic>{};
    final ar = _asString(value['arabic']);
    final en = _asString(value['english']);
    if (ar != null) out['arabic'] = ar;
    if (en != null) out['english'] = en;
    return out.isNotEmpty ? out : null;
  }

  Map<String, dynamic>? get messageError {
    final d = _asMap(detail);
    if (d != null && _asMap(d['messageError']) != null) {
      return _asMap(d['messageError']);
    }
    return _asMap(params['messageError']);
  }

  TerminalMessageErrorInfo? get messageErrorInfo =>
      TerminalMessageErrorInfo.fromMap(messageError);

  NearpayNativeError? get underlying {
    final u = _asMap(params['underlying']);
    if (u != null) return NearpayNativeError(u);
    final d = _asMap(detail);
    if (d != null && _asMap(d['underlying']) != null) {
      return NearpayNativeError(_asMap(d['underlying'])!);
    }
    return null;
  }

  static NearpayNativeError fromNormalizedRecord(Map<String, dynamic> record) =>
      NearpayNativeError(record);

  static NearpayNativeError? fromUnknown(Object? value) {
    if (value is NearpayNativeError) return value;
    if (value is Map)
      return NearpayNativeError(Map<String, dynamic>.from(value));
    return null;
  }

  static NearpayNativeError minimal(String bridgeType, String message) =>
      NearpayNativeError({
        'type': bridgeType.trim().toUpperCase(),
        'message': message,
      });
}

Map<String, dynamic>? _asMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String? _asString(Object? value) => value is String ? value : null;

int? _asInt(Object? value) => value is num ? value.toInt() : null;

String? _trimNonEmpty(Object? value) {
  if (value is! String) return null;
  final t = value.trim();
  return t.isNotEmpty ? t : null;
}

Map<String, dynamic>? _buildNormalizedNativeParams(
  String envelopeMessage,
  String? bridgeType,
  Map<String, dynamic>? raw,
) {
  final base = <String, dynamic>{...(raw ?? {})};

  if (bridgeType != null && bridgeType.trim().isNotEmpty) {
    base['type'] = bridgeType.trim().toUpperCase();
  }
  base.remove('code');
  base['message'] = envelopeMessage;

  final detail = _asMap(base['detail']);
  if (detail != null) {
    final d = <String, dynamic>{...detail};
    final me = _asMap(d['messageError']);
    if (me != null) {
      final m = <String, dynamic>{...me};
      if (m.containsKey('code') && m['type'] == null && m['code'] is num) {
        m['type'] = m['code'];
      }
      m.remove('code');
      d['messageError'] = m;
    }
    base['detail'] = d;
  }

  if (base['localizedMessage'] == null &&
      _asMap(base['displayError']) != null) {
    final de = _asMap(base['displayError'])!;
    Map<String, String> pick(Object? v) {
      final map = _asMap(v);
      if (map == null) return {};
      final out = <String, String>{};
      final ar = _trimNonEmpty(map['arabic']);
      final en = _trimNonEmpty(map['english']);
      if (ar != null) out['arabic'] = ar;
      if (en != null) out['english'] = en;
      return out;
    }

    final fromTitle = pick(de['title']);
    final fromLabel = pick(de['label']);
    final localized = <String, String>{};
    if (fromTitle['arabic'] != null) localized['arabic'] = fromTitle['arabic']!;
    if (fromTitle['english'] != null) {
      localized['english'] = fromTitle['english']!;
    }
    if (fromLabel['arabic'] != null) localized['arabic'] = fromLabel['arabic']!;
    if (fromLabel['english'] != null) {
      localized['english'] = fromLabel['english']!;
    }
    if (localized.isNotEmpty) {
      base['localizedMessage'] = localized;
    }
  }

  final hasContent = base.isNotEmpty ||
      (bridgeType != null && bridgeType.trim().isNotEmpty) ||
      envelopeMessage.trim().isNotEmpty;

  return hasContent ? base : null;
}

NearpayNativeError? normalizeToNativeErrorModel(
  String envelopeMessage,
  String? bridgeType,
  Map<String, dynamic>? raw,
) {
  final plain = _buildNormalizedNativeParams(envelopeMessage, bridgeType, raw);
  if (plain == null) return null;
  return NearpayNativeError.fromNormalizedRecord(plain);
}

bool defaultPrefersArabic() {
  try {
    return Platform.localeName.toLowerCase().startsWith('ar');
  } catch (_) {
    return false;
  }
}

String? pickLocalizedText(
  Map<String, dynamic>? pair,
  bool prefersArabic,
) {
  if (pair == null) return null;
  final ar = _trimNonEmpty(pair['arabic']);
  final en = _trimNonEmpty(pair['english']);
  return prefersArabic ? (ar ?? en) : (en ?? ar);
}

String resolveNearpayUserFacingMessage(
  NearpayNativeError? nativeError,
  String fallbackMessage, [
  bool? prefersArabic,
]) {
  final prefersAr = prefersArabic ?? defaultPrefersArabic();
  if (nativeError != null) {
    final fromTop = pickLocalizedText(nativeError.localizedMessage, prefersAr);
    if (fromTop != null) return fromTop;

    final me = nativeError.messageErrorInfo;
    if (me != null) {
      final fromErr = pickLocalizedText(me.error, prefersAr);
      if (fromErr != null) return fromErr;
      final fromSol = pickLocalizedText(me.solution, prefersAr);
      if (fromSol != null) return fromSol;
    }
  }
  return fallbackMessage;
}
