/// Lowercases transaction/intent ids for callback-map lookup.
///
/// Parity with RN `TerminalModel.normalizeTxnId`.
String normalizeTxnId([String? value]) => (value ?? '').trim().toLowerCase();

String normalizeEventIntentId(String value) => normalizeTxnId(value);

String? _pickTxnId(Map<String, dynamic> args, List<String> keys) {
  for (final key in keys) {
    final value = args[key];
    if (value is String && value.trim().isNotEmpty) {
      return normalizeTxnId(value);
    }
  }
  return null;
}

String resolveTransactionEventTxnId(Map<String, dynamic> args) =>
    _pickTxnId(args, const [
      'transactionUUID',
      'transactionUuid',
      'refundUUID',
      'refundUuid',
      'purchaseUUID',
      'purchaseUuid',
      'intentUUID',
      'intentUuid',
    ]) ??
    '';

String resolveIntentEventTxnId(Map<String, dynamic> args) =>
    _pickTxnId(args, const [
      'intentUUID',
      'intentUuid',
      'intentId',
      'transactionUUID',
      'transactionUuid',
    ]) ??
    '';

String resolveAuthorizationEventTxnId(Map<String, dynamic> args) =>
    _pickTxnId(args, const [
      'uuid',
      'authorizationUUID',
      'authorizationUuid',
      'transactionUUID',
      'transactionUuid',
      'intentUUID',
      'intentUuid',
    ]) ??
    '';

String resolveQrEventRequestId(Map<String, dynamic> args) =>
    _pickTxnId(args, const [
      'requestId',
      'intentUUID',
      'intentUuid',
      'id',
    ]) ??
    '';

String resolveEventTxnId(String eventMethod, Map<String, dynamic> args) {
  switch (eventMethod) {
    case 'purchaseEvent':
    case 'refundEvent':
    case 'purchaseVoidEvent':
    case 'refundVoidEvent':
    case 'openRefundEvent':
    case 'purchaseWithTipEvent':
    case 'installmentsEvent':
      return resolveTransactionEventTxnId(args);
    case 'authorizeEvent':
    case 'authEvent':
    case 'RoutingLookupEvent':
      return resolveIntentEventTxnId(args);
    case 'captureAuthorizationWithTapEvent':
    case 'voidAuthorizationWithTapEvent':
      return resolveAuthorizationEventTxnId(args);
    case 'purchaseWithQREvent':
    case 'qrVoidEvent':
      return resolveQrEventRequestId(args);
    default:
      return resolveIntentEventTxnId(args);
  }
}

String resolveEventIntentId(Map<String, dynamic> args) =>
    resolveIntentEventTxnId(args);

String normalizeCardReaderEventType(String eventType) {
  switch (eventType) {
    case 'waiting':
    case 'notReady':
    case 'readyForTap':
      return 'readerWaiting';
    case 'reading':
    case 'cardDetected':
    case 'removeCard':
      return 'readerReading';
    case 'pinRequested':
    case 'pinEntryRequested':
      return 'pinEntering';
    case 'readingCompleted':
    case 'readCompleted':
    case 'pinEntryCompleted':
      return 'readerFinished';
    case 'readRetry':
      return 'readerRetry';
    case 'readingFailure':
      return 'readerError';
    case 'readCancelled':
    case 'readNotCompleted':
    case 'userInterfaceDismissed':
      return 'readerDismissed';
    case 'readingStarted':
    case 'readerStarted':
      return 'readingStarted';

    case 'preparingToLink':
    case 'linkingStarted':
    case 'relinking':
    case 'linkingCompleted':
    case 'linkingProgress':
    case 'linkingFailure':
      return eventType;
    default:
      return eventType;
  }
}

bool isTerminalResultEventType(String eventType) {
  return eventType == 'sendPurchaseTransactionCompleted' ||
      eventType == 'sendPurchaseWithTipTransactionCompleted' ||
      eventType == 'sendInstallmentsTransactionCompleted' ||
      eventType == 'sendRefundTransactionCompleted' ||
      eventType == 'sendOpenRefundTransactionCompleted' ||
      eventType == 'sendTransactionVoidCompleted' ||
      eventType == 'authorizeCompleted' ||
      eventType == 'authorizeSuccess' ||
      eventType == 'captureWithTapCompleted' ||
      eventType == 'voidWithTapCompleted' ||
      eventType == 'routingLookupCompleted' ||
      eventType == 'sendTransactionFailure' ||
      eventType == 'authorizeFailure' ||
      eventType == 'routingLookupFailure' ||
      eventType == 'onSendTransactionCompleted';
}
