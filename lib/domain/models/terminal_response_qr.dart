part of 'terminal_response.dart';

extension TerminalModelQrOps on TerminalModel {
  Future<String> generateQrCodeWithUi({
    required String id,
    required String amount,
    bool enableUiDismiss = true,
    String? customerReferenceNumber,
    double? lat,
    double? long,
    bool? isLocationFromMock,
    required PurchaseWithQrCallbacks callbacks,
  }) async {
    requireOperationSupported('generateQrCodeWithUi');
    _activePurchaseWithQRCallbacks[_txnKey(id)] = callbacks;

    try {
      final env = await _channel.execute(
        'purchaseWithQR',
        {
          "uuid": terminalUUID,
          "amount": amount,
          "id": id,
          "enableUiDismiss": enableUiDismiss,
          "customerReferenceNumber": customerReferenceNumber,
          if (lat != null) "lat": lat,
          if (long != null) "long": long,
          if (isLocationFromMock != null)
            "isLocationFromMock": isLocationFromMock,
        },
      );
      assertEnvelopeSuccess(env, 'purchaseWithQR',
          fallbackMessage: "Purchase with QR cdoe failed");
      return id;
    } catch (e) {
      _activePurchaseWithQRCallbacks.remove(_txnKey(id));
      rethrow;
    }
  }

  Future<GeneratedQRCode> generateQrCode({
    required String id,
    required String amount,
    String? customerReferenceNumber,
    double? lat,
    double? long,
    bool? isLocationFromMock,
  }) async {
    final env = await _channel.execute(
      'generateQrCode',
      {
        "uuid": terminalUUID,
        "id": id,
        "amount": amount,
        "customerReferenceNumber": customerReferenceNumber,
        if (lat != null) "lat": lat,
        if (long != null) "long": long,
        if (isLocationFromMock != null)
          "isLocationFromMock": isLocationFromMock,
      },
    );
    assertEnvelopeSuccess(env, 'generateQrCode',
        fallbackMessage: "Failed to generate QR code");
    return adaptGeneratedQrCodeResult('generateQrCode', env.data);
  }

  Future<QrStatusResponse> qrStatus({
    required String transactionId,
    String? intentId,
  }) async {
    final env = await _channel.execute(
      'qrStatus',
      {
        "uuid": terminalUUID,
        "transactionId": transactionId,
        if (intentId != null) "intentId": intentId,
      },
    );
    assertEnvelopeSuccess(env, 'qrStatus',
        fallbackMessage: "Failed to fetch QR status");
    return adaptQrStatusResult('qrStatus', env.data);
  }

  Future<void> qrVoid({
    required String intentId,
    required String originalIntentId,
    double? lat,
    double? long,
    bool? isLocationFromMock,
    required QrVoidCallbacks callbacks,
  }) async {
    final normalizedIntentId = intentId.trim();
    if (normalizedIntentId.isEmpty) {
      throw NearpayException('qrVoid requires intentId');
    }
    final normalizedOriginalIntentId = originalIntentId.trim();
    if (normalizedOriginalIntentId.isEmpty) {
      throw NearpayException('qrVoid requires originalIntentId');
    }

    final requestId = _txnKey(
      '$normalizedIntentId:$normalizedOriginalIntentId:'
      '${DateTime.now().millisecondsSinceEpoch}',
    );
    _activeQrVoidCallbacks[requestId] = callbacks;

    try {
      final env = await _channel.execute(
        'qrVoid',
        {
          'uuid': terminalUUID,
          'terminalUUID': terminalUUID,
          'intentId': normalizedIntentId,
          'originalIntentId': normalizedOriginalIntentId,
          'originalIntentID': normalizedOriginalIntentId,
          'requestId': requestId,
          if (lat != null) 'lat': lat,
          if (long != null) 'long': long,
          if (isLocationFromMock != null)
            'isLocationFromMock': isLocationFromMock,
        },
      );
      assertEnvelopeSuccess(env, 'qrVoid', fallbackMessage: 'QR void failed');
    } catch (e) {
      _activeQrVoidCallbacks.remove(requestId);
      rethrow;
    }
  }

  Future<void> qrRefund({
    required String intentId,
    required String originalIntentId,
    Object? amount,
    required QrRefundCallbacks callbacks,
  }) async {
    final normalizedIntentId = intentId.trim();
    if (normalizedIntentId.isEmpty) {
      throw NearpayException('qrRefund requires intentId');
    }
    final normalizedOriginalIntentId = originalIntentId.trim();
    if (normalizedOriginalIntentId.isEmpty) {
      throw NearpayException('qrRefund requires originalIntentId');
    }

    final normalizedAmount = amount?.toString().trim();

    final requestId = _txnKey(
      '$normalizedIntentId:$normalizedOriginalIntentId:'
      '${DateTime.now().millisecondsSinceEpoch}',
    );
    _activeQrRefundCallbacks[requestId] = callbacks;

    try {
      final env = await _channel.execute(
        'qrRefund',
        {
          'uuid': terminalUUID,
          'terminalUUID': terminalUUID,
          'intentId': normalizedIntentId,
          'originalIntentId': normalizedOriginalIntentId,
          'originalIntentID': normalizedOriginalIntentId,
          'requestId': requestId,
          if (normalizedAmount != null && normalizedAmount.isNotEmpty)
            'amount': normalizedAmount,
        },
      );
      assertEnvelopeSuccess(env, 'qrRefund',
          fallbackMessage: 'QR refund failed');
    } catch (e) {
      _activeQrRefundCallbacks.remove(requestId);
      rethrow;
    }
  }
}
