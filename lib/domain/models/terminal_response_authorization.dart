part of 'terminal_response.dart';

extension TerminalModelAuthorizationOps on TerminalModel {
  Future<AuthorizeResponse> authorize({
    required String uuid,
    required int amount,
    PaymentScheme? scheme,
    String? customerReferenceNumber,
    int? surchargeAmount,
    int? taxPercentage,
    num? timestamp,
    required AuthorizedCallbacks callbacks,
  }) async {
    final completer = Completer<AuthorizeResponse>();
    final key = _txnKey(uuid);
    _activeAuthorizeCallbacks[key] =
        wrapAuthorizeCallbacks(callbacks, completer);

    try {
      final env = await _channel.execute(
        'authorize',
        {
          "terminalUUID": terminalUUID,
          "amount": amount,
          "scheme": scheme?.name,
          "uuid": uuid,
          "intentUUID": uuid,
          "intentUuid": uuid,
          "customerReferenceNumber": customerReferenceNumber,
          if (surchargeAmount != null) "surchargeAmount": surchargeAmount,
          if (taxPercentage != null) "taxPercentage": taxPercentage,
          if (timestamp != null) "timestamp": timestamp,
        },
      );
      assertEnvelopeSuccess(env, 'authorize',
          fallbackMessage: "authorize failed");
      return await completer.future;
    } catch (e) {
      _activeAuthorizeCallbacks.remove(key);
      rethrow;
    }
  }

  Future<VoidAuthorizationResponse> voidAuthorization({
    required String uuid,
    int? amount,
  }) async {
    final env = await _channel.execute(
      'voidAuthorization',
      {
        'terminalUUID': terminalUUID,
        'uuid': uuid,
        if (amount != null) 'amount': amount,
      },
    );
    assertEnvelopeSuccess(env, 'voidAuthorization',
        fallbackMessage: 'Failed to void authorization');
    return adaptVoidAuthorizationResult('voidAuthorization', env.data);
  }

  Future<IncrementResponse> incrementAuthorization({
    required String uuid,
    required String authorizationUuid,
    required int amount,
  }) async {
    final env = await _channel.execute(
      'incrementAuthorization',
      {
        'terminalUUID': terminalUUID,
        'uuid': uuid,
        'authorizationUuid': authorizationUuid,
        'amount': amount,
      },
    );
    assertEnvelopeSuccess(env, 'incrementAuthorization',
        fallbackMessage: 'Failed to increment authorization');
    return adaptIncrementResult('incrementAuthorization', env.data);
  }

  Future<String> getPendingTotal() async {
    final env = await _channel.execute(
      'getPendingTotal',
      {
        'terminalUUID': terminalUUID,
      },
    );
    assertEnvelopeSuccess(env, 'getPendingTotal',
        fallbackMessage: 'Failed to get pending total');
    return mapPendingTotal(env.data);
  }

  Future<ProxyRoomResponse> createProxyRoom() async {
    requireOperationSupported('createProxyRoom');
    final env = await _channel.execute('createProxyRoom', {
      'terminalUUID': terminalUUID,
    });
    assertEnvelopeSuccess(env, 'createProxyRoom',
        fallbackMessage: 'Failed to create proxy room');
    return adaptCreateProxyRoomResult('createProxyRoom', env.data);
  }

  Future<TerminalConfig> getTerminalConfig() async {
    final env = await _channel.execute(
      'getTerminalConfig',
      {
        'terminalUUID': terminalUUID,
      },
    );
    assertEnvelopeSuccess(env, 'getTerminalConfig',
        fallbackMessage: 'Failed to get terminal config');
    return adaptTerminalConfigResult('getTerminalConfig', env.data);
  }

  Future<CaptureResponse> captureAuthorization({
    required String uuid,
    required String authorizationUuid,
    required int amount,
  }) async {
    final env = await _channel.execute(
      'captureAuthorization',
      {
        'terminalUUID': terminalUUID,
        'authorizationUuid': authorizationUuid,
        'uuid': uuid,
        'amount': amount,
      },
    );
    assertEnvelopeSuccess(env, 'captureAuthorization',
        fallbackMessage: 'Failed to capture authorization');
    return adaptCaptureResult('captureAuthorization', env.data);
  }

  Future<CaptureResponse> captureAuthorizationWithTap({
    required String uuid,
    required String authorizationUuid,
    required int amount,
    required CaptureAuthorizationWithTapCallbacks callbacks,
  }) async {
    requireOperationSupported('captureAuthorizationWithTap');
    final completer = Completer<CaptureResponse>();
    final key = _txnKey(uuid);
    _activeCaptureAuthorizationWithTapCallbacks[key] =
        wrapCaptureWithTapCallbacks(callbacks, completer);
    try {
      final env = await _channel.execute(
        'captureAuthorizationWithTap',
        {
          'terminalUUID': terminalUUID,
          'authorizationUuid': authorizationUuid,
          'uuid': uuid,
          'amount': amount,
        },
      );
      assertEnvelopeSuccess(env, 'captureAuthorizationWithTap',
          fallbackMessage: 'Failed to capture authorization');
      return await completer.future;
    } catch (e) {
      _activeCaptureAuthorizationWithTapCallbacks.remove(key);
      rethrow;
    }
  }

  Future<VoidAuthorizationResponse> voidAuthorizationWithTap({
    required String uuid,
    required String authorizationUuid,
    required int amount,
    String? customerReferenceNumber,
    required VoidAuthorizationWithTapCallbacks callbacks,
  }) async {
    requireOperationSupported('voidAuthorizationWithTap');
    final completer = Completer<VoidAuthorizationResponse>();
    final key = _txnKey(authorizationUuid);
    _activeVoidAuthorizationWithTapCallbacks[key] =
        wrapVoidAuthorizationWithTapCallbacks(callbacks, completer);
    try {
      final env = await _channel.execute(
        'voidAuthorizationWithTap',
        {
          'terminalUUID': terminalUUID,
          'authorizationUuid': authorizationUuid,
          'authorizationUUID': authorizationUuid,
          'uuid': uuid,
          'amount': amount,
          if (customerReferenceNumber != null)
            'customerReferenceNumber': customerReferenceNumber,
        },
      );
      assertEnvelopeSuccess(env, 'voidAuthorizationWithTap',
          fallbackMessage: 'Failed to void authorization');
      return await completer.future;
    } catch (e) {
      _activeVoidAuthorizationWithTapCallbacks.remove(key);
      rethrow;
    }
  }
}
