part of 'terminal_response.dart';

extension TerminalModelRefundOps on TerminalModel {
  Future<RefundResponse> refund({
    required String intentUUID,
    String? refundUUID,
    String? refundUuid,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    String? refundRRN,
    double? timestamp,
    required RefundCallbacks callbacks,
  }) async {
    final newRefundIntentUUID = refundUUID != null && refundUUID.trim().isNotEmpty
        ? refundUUID.trim()
        : (refundUuid?.trim() ?? '');
    if (newRefundIntentUUID.isEmpty) {
      throw NearpayException('refund requires refundUUID or refundUuid');
    }
    final originalIntentUUID = intentUUID.trim();
    if (originalIntentUUID.isEmpty) {
      throw NearpayException('refund requires intentUUID');
    }

    final completer = Completer<RefundResponse>();
    final key = _refundCallbackKey(
      newRefundIntentUUID: newRefundIntentUUID,
      originalIntentUUID: originalIntentUUID,
    );
    _activeRefundCallbacks[key] = wrapRefundCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'refund',
        buildRefundChannelPayload(
          terminalUUID: terminalUUID,
          newRefundIntentUUID: newRefundIntentUUID,
          originalIntentUUID: originalIntentUUID,
          amount: amount,
          customerReferenceNumber: customerReferenceNumber,
          scheme: scheme?.name,
          refundRRN: refundRRN,
          timestamp: timestamp,
        ),
      );
      assertEnvelopeSuccess(env, 'refund', fallbackMessage: "Refund failed");
      return await completer.future;
    } catch (e) {
      _activeRefundCallbacks.remove(key);
      rethrow;
    }
  }

  Future<RefundResponse> refundWithoutTap({
    required String intentUUID,
    String? refundUUID,
    String? refundUuid,
    int? amount,
    String? customerReferenceNumber,
    required RefundCallbacks callbacks,
  }) async {
    final newRefundIntentUUID = refundUUID != null && refundUUID.trim().isNotEmpty
        ? refundUUID.trim()
        : (refundUuid?.trim() ?? '');
    if (newRefundIntentUUID.isEmpty) {
      throw NearpayException(
          'refundWithoutTap requires refundUUID or refundUuid');
    }
    final originalIntentUUID = intentUUID.trim();
    if (originalIntentUUID.isEmpty) {
      throw NearpayException('refundWithoutTap requires intentUUID');
    }

    final completer = Completer<RefundResponse>();
    final key = _refundCallbackKey(
      newRefundIntentUUID: newRefundIntentUUID,
      originalIntentUUID: originalIntentUUID,
    );
    _activeRefundCallbacks[key] = wrapRefundCallbacks(callbacks, completer);

    final channelIntentUUID = originalIntentUUID;
    final channelRefundUUID = newRefundIntentUUID;

    try {
      final env = await _channel.execute(
        'refundWithoutTap',
        {
          'terminalUUID': terminalUUID,
          'intentUUID': channelIntentUUID,
          'intentUuid': channelIntentUUID,
          'refundUUID': channelRefundUUID,
          'refundUuid': channelRefundUUID,
          if (amount != null) 'amount': amount,
          if (customerReferenceNumber != null)
            'customerReferenceNumber': customerReferenceNumber,
        },
      );
      assertEnvelopeSuccess(env, 'refundWithoutTap',
          fallbackMessage: "Refund failed");
      return await completer.future;
    } catch (e) {
      _activeRefundCallbacks.remove(key);
      rethrow;
    }
  }

  Future<RefundResponse> openRefund({
    required String intentUUID,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    double? timestamp,
    required OpenRefundCallbacks callbacks,
  }) async {
    final completer = Completer<RefundResponse>();
    final key = _txnKey(intentUUID);
    _activeOpenRefundCallbacks[key] =
        wrapOpenRefundCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'openRefund',
        {
          "terminalUUID": terminalUUID,
          "intentUUID": intentUUID,
          "amount": amount,
          if (timestamp != null) "timestamp": timestamp,
          "customerReferenceNumber": customerReferenceNumber,
          "scheme": scheme?.name,
        },
      );
      assertEnvelopeSuccess(env, 'openRefund',
          fallbackMessage: "Refund failed");
      return await completer.future;
    } catch (e) {
      _activeOpenRefundCallbacks.remove(key);
      rethrow;
    }
  }

  Future<IntentResponseTurkey> refundVoid({
    required String intentUUID,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required RefundVoidCallbacks callbacks,
  }) async {
    requireOperationSupported('refundVoid');
    final completer = Completer<IntentResponseTurkey>();
    final key = _txnKey(intentUUID);
    _activeRefundVoidCallbacks[key] =
        wrapRefundVoidCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'refundVoid',
        {
          "terminalUUID": terminalUUID,
          "intentUUID": intentUUID,
          "amount": amount,
          "customerReferenceNumber": customerReferenceNumber,
          "scheme": scheme?.name,
        },
      );
      assertEnvelopeSuccess(env, 'refundVoid',
          fallbackMessage: "Refund failed");
      return await completer.future;
    } catch (e) {
      _activeRefundVoidCallbacks.remove(key);
      rethrow;
    }
  }
}
