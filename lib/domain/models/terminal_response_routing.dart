part of 'terminal_response.dart';

extension TerminalModelRoutingOps on TerminalModel {
  Future<String> routingLookup({
    required String intentUUID,
    required int amount,
    PaymentScheme? scheme,
    double? lat,
    double? long,
    bool? isLocationFromMock,
    required RoutingLookupCallbacks callbacks,
  }) async {
    requireOperationSupported('routingLookup');
    _activeRoutingLookupCallbacks[_txnKey(intentUUID)] = callbacks;

    try {
      final env = await _channel.execute(
        'routingLookup',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "scheme": scheme?.name,
          "intentUUID": intentUUID,
          if (lat != null) "lat": lat,
          if (long != null) "long": long,
          if (isLocationFromMock != null)
            "isLocationFromMock": isLocationFromMock,
        },
      );
      assertEnvelopeSuccess(env, 'routingLookup',
          fallbackMessage: "Routing lookup failed");
      return intentUUID;
    } catch (e) {
      _activeRoutingLookupCallbacks.remove(_txnKey(intentUUID));
      rethrow;
    }
  }

  Future<PurchaseResponse> routingExecute({
    required String selectedAcquirerTerminalId,
    required String sessionId,
    String? customerReferenceNumber,
  }) async {
    requireOperationSupported('routingExecute');
    try {
      final env = await _channel.execute(
        'routingExecute',
        {
          "uuid": terminalUUID,
          "selectedAcquirerTerminalId": selectedAcquirerTerminalId,
          "customerReferenceNumber": customerReferenceNumber,
          "sessionId": sessionId
        },
      );
      assertEnvelopeSuccess(env, 'routingExecute', fallbackMessage: "Get");
      return adaptPurchaseResult('routingExecute', env.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PurchaseResponse> routingInstallments({
    required String selectedAcquirerTerminalId,
    required String sessionId,
    required List<InstallmentOption> installmentOptions,
    String? customerReferenceNumber,
  }) async {
    requireOperationSupported('routingInstallments');
    try {
      final env = await _channel.execute(
        'routingInstallments',
        {
          "uuid": terminalUUID,
          "selectedAcquirerTerminalId": selectedAcquirerTerminalId,
          "customerReferenceNumber": customerReferenceNumber,
          "sessionId": sessionId,
          "installmentOptions":
              installmentOptions.map((option) => option.toJson()).toList(),
        },
      );
      assertEnvelopeSuccess(env, 'routingInstallments',
          fallbackMessage: "Routing installments failed");
      return adaptPurchaseResult('routingInstallments', env.data);
    } catch (e) {
      rethrow;
    }
  }
}
