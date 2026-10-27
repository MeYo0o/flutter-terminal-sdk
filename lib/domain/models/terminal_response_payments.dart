part of 'terminal_response.dart';

extension TerminalModelPaymentOps on TerminalModel {
  Future<ReverseResponse> reverseTransaction({
    required Object intent,
  }) async {
    final intentId = resolveReverseIntentId(intent);
    final env = await _channel.execute(
      'reverseTransaction',
      {
        'terminalUUID': terminalUUID,
        'intentId': intentId,
      },
    );
    assertEnvelopeSuccess(env, 'reverseTransaction',
        fallbackMessage: 'Failed to reverse transaction');
    return adaptReverseResult('reverseTransaction', env.data);
  }

  Future<PurchaseResponse> purchase({
    required String intentUUID,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    int? surchargeAmount,
    int? taxPercentage,
    num? timestamp,
    bool withTokenization = false,
    required PurchaseCallbacks callbacks,
  }) async {
    final completer = Completer<PurchaseResponse>();
    final key = _txnKey(intentUUID);
    _activePurchaseCallbacks[key] = wrapPurchaseCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'purchase',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "scheme": scheme?.name,
          "intentUUID": intentUUID,
          "customerReferenceNumber": customerReferenceNumber,
          if (surchargeAmount != null) "surchargeAmount": surchargeAmount,
          if (taxPercentage != null) "taxPercentage": taxPercentage,
          if (timestamp != null) "timestamp": timestamp,
          if (withTokenization) "withTokenization": withTokenization,
        },
      );
      assertEnvelopeSuccess(env, 'purchase',
          fallbackMessage: "Purchase failed");
      return await completer.future;
    } catch (e) {
      _activePurchaseCallbacks.remove(key);
      rethrow;
    }
  }

  Future<PurchaseResponse> purchaseWithTokenization({
    required String intentUUID,
    required String tokenizationID,
    required int amount,
    String? customerReferenceNumber,
    int? surchargeAmount,
    int? taxPercentage,
    required PurchaseCallbacks callbacks,
  }) async {
    if (tokenizationID.trim().isEmpty) {
      throw NearpayException(
          'purchaseWithTokenization requires tokenizationID');
    }

    final completer = Completer<PurchaseResponse>();
    final key = _txnKey(intentUUID);
    _activePurchaseCallbacks[key] = wrapPurchaseCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'purchaseWithTokenization',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "intentUUID": intentUUID,
          "tokenizationID": tokenizationID,
          "tokenizationId": tokenizationID,
          "customerReferenceNumber": customerReferenceNumber,
          if (surchargeAmount != null) "surchargeAmount": surchargeAmount,
          if (taxPercentage != null) "taxPercentage": taxPercentage,
        },
      );
      assertEnvelopeSuccess(env, 'purchaseWithTokenization',
          fallbackMessage: "Purchase failed");
      return await completer.future;
    } catch (e) {
      _activePurchaseCallbacks.remove(key);
      rethrow;
    }
  }

  Future<PurchaseResponse> purchaseWithTip({
    required String intentUUID,
    required int amount,
    required int amountOther,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    int? surchargeAmount,
    int? taxPercentage,
    num? timestamp,
    required PurchaseCallbacks callbacks,
  }) async {
    final completer = Completer<PurchaseResponse>();
    final key = _txnKey(intentUUID);
    _activePurchaseWithTipCallbacks[key] =
        wrapPurchaseCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'purchaseWithTip',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "amountOther": amountOther,
          "scheme": scheme?.name,
          "intentUUID": intentUUID,
          "customerReferenceNumber": customerReferenceNumber,
          if (surchargeAmount != null) "surchargeAmount": surchargeAmount,
          if (taxPercentage != null) "taxPercentage": taxPercentage,
          if (timestamp != null) "timestamp": timestamp,
        },
      );
      assertEnvelopeSuccess(env, 'purchaseWithTip',
          fallbackMessage: "Purchase failed");
      return await completer.future;
    } catch (e) {
      _activePurchaseWithTipCallbacks.remove(key);
      rethrow;
    }
  }

  Future<PurchaseResponse> installments({
    required String intentUUID,
    required int amount,
    required int numberOfInstallments,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required PurchaseCallbacks callbacks,
  }) async {
    requireOperationSupported('installments');
    final completer = Completer<PurchaseResponse>();
    final key = _txnKey(intentUUID);
    _activeInstallmentsCallbacks[key] =
        wrapPurchaseCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'installments',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "numberOfInstallments": numberOfInstallments,
          "scheme": scheme?.name,
          "intentUUID": intentUUID,
          "customerReferenceNumber": customerReferenceNumber,
        },
      );
      assertEnvelopeSuccess(env, 'installments',
          fallbackMessage: "Purchase failed");
      return await completer.future;
    } catch (e) {
      _activeInstallmentsCallbacks.remove(key);
      rethrow;
    }
  }

  Future<IntentResponseTurkey> purchaseVoid({
    required String intentUUID,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    required PurchaseVoidCallbacks callbacks,
  }) async {
    requireOperationSupported('purchaseVoid');
    final completer = Completer<IntentResponseTurkey>();
    final key = _txnKey(intentUUID);
    _activePurchaseVoidCallbacks[key] =
        wrapPurchaseVoidCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'purchaseVoid',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "scheme": scheme?.name,
          "intentUUID": intentUUID,
          "customerReferenceNumber": customerReferenceNumber,
        },
      );
      assertEnvelopeSuccess(env, 'purchaseVoid',
          fallbackMessage: "Purchase failed");
      return await completer.future;
    } catch (e) {
      _activePurchaseVoidCallbacks.remove(key);
      rethrow;
    }
  }

  Future<PurchaseResponse> tipTransaction({
    required String id,
    required int amount,
  }) async {
    try {
      final env = await _channel.execute(
        'tipTransaction',
        {
          "terminalUUID": terminalUUID,
          "id": id,
          "amount": amount,
        },
      );
      assertEnvelopeSuccess(env, 'tipTransaction',
          fallbackMessage: "Tip failed");
      return adaptPurchaseResult('tipTransaction', env.data);
    } catch (e) {
      rethrow;
    }
  }
}
