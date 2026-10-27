import '../../../errors/errors.dart';

String resolveIntentId(Map<String, dynamic> params, String op) {
  final fromCanonical = params['intentUUID']?.toString().trim() ?? '';
  final fromLegacy = params['intentUuid']?.toString().trim() ?? '';
  final intentUUID = fromCanonical.isNotEmpty ? fromCanonical : fromLegacy;
  if (intentUUID.isEmpty) {
    throw NearpayException('$op requires intentUUID or intentUuid');
  }
  return intentUUID;
}

String resolveRefundId(Map<String, dynamic> params, String op) {
  final fromCanonical = params['refundUUID']?.toString().trim() ?? '';
  final fromLegacy = params['refundUuid']?.toString().trim() ?? '';
  final refundUUID = fromCanonical.isNotEmpty ? fromCanonical : fromLegacy;
  if (refundUUID.isEmpty) {
    throw NearpayException('$op requires refundUUID or refundUuid');
  }
  return refundUUID;
}

String resolveAuthorizationId(Map<String, dynamic> params, String op) {
  final fromCanonical = params['authorizationUUID']?.toString().trim() ?? '';
  final fromLegacy = params['authorizationUuid']?.toString().trim() ?? '';
  final authorizationUUID =
      fromCanonical.isNotEmpty ? fromCanonical : fromLegacy;
  if (authorizationUUID.isEmpty) {
    throw NearpayException(
        '$op requires authorizationUUID or authorizationUuid');
  }
  return authorizationUUID;
}

String resolveCancelId(Map<String, dynamic> params) {
  for (final key in ['id', 'transactionUUID', 'transactionUuid']) {
    final value = params[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  throw NearpayException('cancelTransaction requires id');
}

String resolveReverseIntentId(Object intent) {
  if (intent is String) {
    final trimmed = intent.trim();
    if (trimmed.isEmpty) {
      throw NearpayException(
          'reverseTransaction requires intentId, intentUUID, or intentUuid');
    }
    return trimmed;
  }
  if (intent is Map<String, dynamic>) {
    return resolveIntentId(intent, 'reverseTransaction');
  }
  if (intent is Map) {
    return resolveIntentId(
        Map<String, dynamic>.from(intent), 'reverseTransaction');
  }
  throw NearpayException(
      'reverseTransaction requires intentId, intentUUID, or intentUuid');
}
