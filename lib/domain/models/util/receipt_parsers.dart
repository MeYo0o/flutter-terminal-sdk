import 'package:flutter_terminal_sdk/domain/models/util/json_pick.dart';
import 'package:flutter_terminal_sdk/domain/models/util/receipt_normalizers.dart';
import 'package:flutter_terminal_sdk/domain/models/data/dto/transaction_response_turkey.dart';
import 'package:flutter_terminal_sdk/domain/models/data/dto/transaction_response_usa.dart';

ReceiptDataTurkey? parseBkmReceipt(dynamic data) {
  final parsed = parseReceiptPayload(data);
  if (parsed == null) return null;
  try {
    final type = pickKey(parsed, ['type'])?.toString().toUpperCase();
    if (type != 'BKM') return null;
    final txUuid = pickKey(
      parsed,
      ['transaction_uuid', 'transactionUuid', 'transactionUUID'],
    );
    if (txUuid is! String || txUuid.trim().isEmpty) return null;
    return ReceiptDataTurkey.fromJson(parsed);
  } catch (_) {
    return null;
  }
}

AuthorizeReceipt? parseEpxReceipt(dynamic data) {
  final parsed = parseReceiptPayload(data);
  if (parsed == null) return null;
  try {
    final supportedLanguages = pickKey(
      parsed,
      ['supportedLanguages', 'supported_languages'],
    );
    final receiptType = pickKey(parsed, ['receiptType', 'receipt_type']);
    if (supportedLanguages == null && receiptType == null) return null;
    return AuthorizeReceipt.fromJson(parsed);
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? normalizeMadaReceiptPayload(dynamic data) {
  final parsed = parseReceiptPayload(data);
  if (parsed == null) return null;
  try {
    final type = pickKey(parsed, ['type'])?.toString().toUpperCase();
    if (type == 'BKM' || type == 'EPX') return null;
    if (pickMap(parsed, ['merchant']) == null) return null;
    final cardSchemeJson = normalizeReceiptCardSchemeJson(
      pickKey(parsed, ['card_scheme', 'cardScheme']),
    );
    if (cardSchemeJson == null) return null;
    final normalized = Map<String, dynamic>.from(parsed);
    normalized['card_scheme'] = cardSchemeJson;
    normalized['cardScheme'] = cardSchemeJson;
    return normalized;
  } catch (_) {
    return null;
  }
}
