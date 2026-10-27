part of 'terminal_response.dart';

void _handleQrEvent(
  String eventType,
  String? message,
  data,
  PurchaseWithQrCallbacks callbacks,
) {
  switch (eventType) {
    case 'qrUiPresented':
      if (data != null) {
        try {
          final generatedQRCode =
              adaptGeneratedQrCodeResult('qrUiPresented', data);
          callbacks.onQrUiPresented?.call(generatedQRCode);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing GeneratedQRCode: $e"));
        }
      }
      break;
    case 'qrPaymentStatusUpdated':
      if (data != null) {
        try {
          final qrStatusResponse =
              adaptQrStatusResult('qrPaymentStatusUpdated', data);
          callbacks.onQrPaymentStatusUpdated?.call(qrStatusResponse);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing QrStatusResponse: $e"));
        }
      }
      break;
    case 'qrPaymentStatusExpired':
      if (data != null) {
        try {
          final qrStatusResponse =
              adaptQrStatusResult('qrPaymentStatusExpired', data);
          callbacks.onQrPaymentStatusExpired?.call(qrStatusResponse);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing QrStatusResponse: $e"));
        }
      }
      break;
    case 'qrPaymentStatusCancelled':
      if (data != null) {
        try {
          final qrStatusResponse =
              adaptQrStatusResult('qrPaymentStatusCancelled', data);
          callbacks.onQrPaymentStatusCancelled?.call(qrStatusResponse);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing QrStatusResponse: $e"));
        }
      }
      break;
    case 'qrPaymentStatusCompleted':
      if (data != null) {
        try {
          final qrStatusResponse =
              adaptQrStatusResult('qrPaymentStatusCompleted', data);
          callbacks.onQrPaymentStatusCompleted?.call(qrStatusResponse);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing QrStatusResponse: $e"));
        }
      }
      break;
    case 'qrPaymentApproved':
      if (data != null) {
        try {
          final purchaseResponse =
              adaptQRPurchaseResponseResult('qrPaymentApproved', data);
          callbacks.onQrPaymentApproved?.call(purchaseResponse);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing PurchaseResponse: $e"));
        }
      }
      break;
    case 'qrPaymentDeclined':
      if (data != null) {
        try {
          final purchaseResponse =
              adaptQRPurchaseResponseResult('qrPaymentDeclined', data);
          callbacks.onQrPaymentDeclined?.call(purchaseResponse);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing PurchaseResponse: $e"));
        }
      }
      break;
    case 'qrPaymentFailure':
      callbacks.onNearpayException
          ?.call(NearpayException(message ?? 'QR payment failed'));
      break;
    case 'qrPaymentStatusFailed':
      if (data != null) {
        try {
          final qrStatusResponse =
              adaptQrStatusResult('qrPaymentStatusFailed', data);
          callbacks.onQrPaymentStatusFailed?.call(qrStatusResponse);
        } catch (e) {
          callbacks.onNearpayException
              ?.call(NearpayException("Error parsing QrStatusResponse: $e"));
        }
      }
      break;
    case "uiClosed":
      callbacks.onUiClosed?.call();
      break;
  }
}

extension TerminalModelEventRouting on TerminalModel {
  void _dispatchChannelEvent({
    required String txnId,
    required String eventType,
    required String? message,
    required Map<String, dynamic>? data,
    required dynamic registeredCallbacks,
    required Function? onSuccess,
    required Function(String)? onFailure,
    required void Function() onTerminalComplete,
  }) {
    if (isTerminalResultEventType(eventType) && registeredCallbacks == null) {
      if (kDebugMode) {
        debugPrint(
            "No active callbacks for terminal result $eventType txnId: $txnId");
      }
      return;
    }

    _handleEvent(
      eventType,
      message,
      data,
      cardReaderCallbacks: _cardReaderCallbacksFrom(registeredCallbacks) ??
          _lookupCardReaderCallbacks(txnId),
      linkingCallbacks: _linkingCallbacksFrom(registeredCallbacks) ??
          _lookupLinkingCallbacks(txnId),
      onSuccess: onSuccess,
      onFailure: onFailure,
      onTerminalComplete: onTerminalComplete,
    );
  }

  void _dispatchQrVoidEvent({
    required String requestId,
    required String eventType,
    String? message,
    Object? data,
  }) {
    final callbacks = _activeQrVoidCallbacks[_txnKey(requestId)];
    if (callbacks == null) {
      if (kDebugMode) {
        debugPrint('No active qrVoid callbacks for requestId: $requestId');
      }
      return;
    }

    final key = _txnKey(requestId);

    switch (eventType) {
      case 'onQrVoidQrCodeGenerated':
        if (data != null) {
          try {
            callbacks.onQrVoidQrCodeGenerated?.call(
              adaptGeneratedQrCodeResult('qrVoid', data),
            );
          } catch (e) {
            final error = ensureNearpayException(
              'Error parsing GeneratedQRCode: $e',
            );
            callbacks.onQrVoidFailure?.call(error);
            callbacks.onNearpayException?.call(error);
          }
        }
        break;
      case 'onQrUiPresented':
        _qrVoidUiPresented.add(key);
        if (data != null) {
          try {
            callbacks.onQrUiPresented?.call(
              adaptGeneratedQrCodeResult('qrVoid', data),
            );
          } catch (e) {
            final error = ensureNearpayException(
              'Error parsing GeneratedQRCode: $e',
            );
            callbacks.onQrVoidFailure?.call(error);
            callbacks.onNearpayException?.call(error);
          }
        }
        break;
      case 'onUiClosed':
        callbacks.onUiClosed?.call();
        _qrVoidUiPresented.remove(key);
        _activeQrVoidCallbacks.remove(key);
        break;
      case 'onQrVoidSuccess':
        if (data != null) {
          try {
            callbacks.onQrVoidSuccess?.call(
              adaptQrStatusResult('qrVoid', data),
            );
          } catch (e) {
            final error = ensureNearpayException(
              'Error parsing QrStatusResponse: $e',
            );
            callbacks.onQrVoidFailure?.call(error);
            callbacks.onNearpayException?.call(error);
          }
        }
        if (!_qrVoidUiPresented.contains(key)) {
          _activeQrVoidCallbacks.remove(key);
        }
        break;
      case 'onQrVoidFailure':
        final error = ensureNearpayException(
          data is Map ? data : message,
          message ?? 'QR void failed',
        );
        callbacks.onQrVoidFailure?.call(error);
        callbacks.onNearpayException?.call(error);
        if (!_qrVoidUiPresented.contains(key)) {
          _activeQrVoidCallbacks.remove(key);
        }
        break;
    }
  }

  void _dispatchQrRefundEvent({
    required String requestId,
    required String eventType,
    String? message,
    Object? data,
  }) {
    final callbacks = _activeQrRefundCallbacks[_txnKey(requestId)];
    if (callbacks == null) {
      if (kDebugMode) {
        debugPrint('No active qrRefund callbacks for requestId: $requestId');
      }
      return;
    }

    final key = _txnKey(requestId);

    switch (eventType) {
      case 'onQrRefundQrCodeGenerated':
        if (data != null) {
          try {
            callbacks.onQrRefundQrCodeGenerated?.call(
              adaptGeneratedQrCodeResult('qrRefund', data),
            );
          } catch (e) {
            final error = ensureNearpayException(
              'Error parsing GeneratedQRCode: $e',
            );
            callbacks.onQrRefundFailure?.call(error);
            callbacks.onNearpayException?.call(error);
          }
        }
        break;
      case 'onQrUiPresented':
        _qrRefundUiPresented.add(key);
        if (data != null) {
          try {
            callbacks.onQrUiPresented?.call(
              adaptGeneratedQrCodeResult('qrRefund', data),
            );
          } catch (e) {
            final error = ensureNearpayException(
              'Error parsing GeneratedQRCode: $e',
            );
            callbacks.onQrRefundFailure?.call(error);
            callbacks.onNearpayException?.call(error);
          }
        }
        break;
      case 'onUiClosed':
        callbacks.onUiClosed?.call();
        _qrRefundUiPresented.remove(key);
        _activeQrRefundCallbacks.remove(key);
        break;
      case 'onQrRefundSuccess':
        if (data != null) {
          try {
            callbacks.onQrRefundSuccess?.call(
              adaptQrStatusResult('qrRefund', data),
            );
          } catch (e) {
            final error = ensureNearpayException(
              'Error parsing QrStatusResponse: $e',
            );
            callbacks.onQrRefundFailure?.call(error);
            callbacks.onNearpayException?.call(error);
          }
        }
        if (!_qrRefundUiPresented.contains(key)) {
          _activeQrRefundCallbacks.remove(key);
        }
        break;
      case 'onQrRefundFailure':
        final error = ensureNearpayException(
          data is Map ? data : message,
          message ?? 'QR refund failed',
        );
        callbacks.onQrRefundFailure?.call(error);
        callbacks.onNearpayException?.call(error);
        if (!_qrRefundUiPresented.contains(key)) {
          _activeQrRefundCallbacks.remove(key);
        }
        break;
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    try {
      if (call.method == 'qrVoidEvent') {
        final rawArgs = call.arguments;
        if (rawArgs is! Map) {
          if (kDebugMode) {
            debugPrint(
                'Ignoring qrVoidEvent: expected map arguments, got $rawArgs');
          }
          return;
        }
        final args = Map<String, dynamic>.from(rawArgs);
        final requestId = resolveQrEventRequestId(args);
        final eventType = args['type']?.toString() ?? '';
        if (requestId.isEmpty || eventType.isEmpty) {
          if (kDebugMode) {
            debugPrint(
                'Ignoring qrVoidEvent: missing requestId or type ($eventType)');
          }
          return;
        }
        _dispatchQrVoidEvent(
          requestId: requestId,
          eventType: eventType,
          message: args['message'] as String?,
          data: args['data'],
        );
        return;
      }

      if (call.method == 'qrRefundEvent') {
        final rawArgs = call.arguments;
        if (rawArgs is! Map) {
          if (kDebugMode) {
            debugPrint(
                'Ignoring qrRefundEvent: expected map arguments, got $rawArgs');
          }
          return;
        }
        final args = Map<String, dynamic>.from(rawArgs);
        final requestId = resolveQrEventRequestId(args);
        final eventType = args['type']?.toString() ?? '';
        if (requestId.isEmpty || eventType.isEmpty) {
          if (kDebugMode) {
            debugPrint(
                'Ignoring qrRefundEvent: missing requestId or type ($eventType)');
          }
          return;
        }
        _dispatchQrRefundEvent(
          requestId: requestId,
          eventType: eventType,
          message: args['message'] as String?,
          data: args['data'],
        );
        return;
      }

      if (call.method == 'nfcShareEvent') {
        final rawArgs = call.arguments;
        if (rawArgs is! Map) {
          if (kDebugMode) {
            debugPrint(
                'Ignoring nfcShareEvent: expected map arguments, got $rawArgs');
          }
          return;
        }
        final args = Map<String, dynamic>.from(rawArgs);
        final sessionId = args['sessionId']?.toString() ?? '';
        final eventType = args['type']?.toString() ?? '';
        if (sessionId.isEmpty || eventType.isEmpty) {
          if (kDebugMode) {
            debugPrint(
                'Ignoring nfcShareEvent: missing sessionId or type ($eventType)');
          }
          return;
        }

        final callbacks = _activeNfcShareCallbacks[_txnKey(sessionId)];
        if (callbacks == null) {
          if (kDebugMode) {
            debugPrint(
                'No active NFC share callbacks for sessionId: $sessionId');
          }
          return;
        }

        final rawData = args['data'];
        Map<String, dynamic>? data;
        if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        }

        switch (eventType) {
          case 'onStarted':
            callbacks.onStarted?.call();
            break;
          case 'onShared':
            callbacks.onShared?.call();
            break;
          case 'onStopped':
            _activeNfcShareCallbacks.remove(_txnKey(sessionId));
            callbacks.onStopped?.call();
            break;
          case 'onFailure':
            _activeNfcShareCallbacks.remove(_txnKey(sessionId));
            callbacks.onFailure?.call(parseNfcShareFailure(data));
            break;
        }
        return;
      }

      if (call.method == 'purchaseEvent' ||
          call.method == 'refundEvent' ||
          call.method == 'purchaseVoidEvent' ||
          call.method == 'refundVoidEvent' ||
          call.method == 'openRefundEvent' ||
          call.method == 'authorizeEvent' ||
          call.method == 'authEvent' ||
          call.method == 'captureAuthorizationWithTapEvent' ||
          call.method == 'voidAuthorizationWithTapEvent' ||
          call.method == 'purchaseWithTipEvent' ||
          call.method == 'installmentsEvent' ||
          call.method == 'purchaseWithQREvent' ||
          call.method == 'RoutingLookupEvent') {
        final rawArgs = call.arguments;
        if (rawArgs is! Map) {
          if (kDebugMode) {
            debugPrint(
                'Ignoring ${call.method}: expected map arguments, got $rawArgs');
          }
          return;
        }
        final args = Map<String, dynamic>.from(rawArgs);
        final txnId = resolveEventTxnId(call.method, args);
        final eventType = args['type']?.toString() ?? '';
        final message = args['message'] as String?;
        if (eventType.isEmpty) {
          if (kDebugMode) {
            debugPrint('Ignoring ${call.method}: missing event type');
          }
          return;
        }
        if (txnId.isEmpty) {
          if (kDebugMode) {
            debugPrint(
                "Ignoring ${call.method} without transaction id: type=$eventType");
          }
          return;
        }
        if (!_ownsTransaction(call.method, txnId)) {
          return;
        }
        if (kDebugMode) {
          debugPrint(
              "Received $eventType for txnId $txnId: message => $message");
        }

        final rawData = args['data'];
        Map<String, dynamic>? data;

        if (rawData is String) {
          try {
            data = jsonDecode(rawData);
          } catch (_) {}
        } else if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData);
        }

        switch (call.method) {
          case 'purchaseEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activePurchaseCallbacks[txnId],
              onSuccess: _activePurchaseCallbacks[txnId]
                  ?.onTransactionPurchaseCompleted,
              onFailure:
                  _activePurchaseCallbacks[txnId]?.onSendTransactionFailure,
              onTerminalComplete: () => _activePurchaseCallbacks.remove(txnId),
            );
            break;
          case 'RoutingLookupEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activeRoutingLookupCallbacks[txnId],
              onSuccess: _activeRoutingLookupCallbacks[txnId]
                  ?.onRoutingLookupCompleted,
              onFailure: _activeRoutingLookupCallbacks[txnId]
                  ?.onSendTransactionFailure,
              onTerminalComplete: () =>
                  _activeRoutingLookupCallbacks.remove(txnId),
            );
            break;
          case 'purchaseWithQREvent':
            final PurchaseWithQrCallbacks? callbacks =
                _activePurchaseWithQRCallbacks[txnId];

            if (callbacks == null) {
              if (kDebugMode) {
                debugPrint(
                    "No active purchase with qr callbacks for id: $txnId");
              }
              return;
            }

            _handleQrEvent(
              eventType,
              message,
              data,
              callbacks,
            );

            break;

          case 'installmentsEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activeInstallmentsCallbacks[txnId],
              onSuccess: _activeInstallmentsCallbacks[txnId]
                  ?.onTransactionPurchaseCompleted,
              onFailure:
                  _activeInstallmentsCallbacks[txnId]?.onSendTransactionFailure,
              onTerminalComplete: () =>
                  _activeInstallmentsCallbacks.remove(txnId),
            );
            break;
          case 'purchaseWithTipEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activePurchaseWithTipCallbacks[txnId],
              onSuccess: _activePurchaseWithTipCallbacks[txnId]
                  ?.onTransactionPurchaseCompleted,
              onFailure: _activePurchaseWithTipCallbacks[txnId]
                  ?.onSendTransactionFailure,
              onTerminalComplete: () =>
                  _activePurchaseWithTipCallbacks.remove(txnId),
            );
            break;
          case 'authorizeEvent':
          case 'authEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activeAuthorizeCallbacks[txnId],
              onSuccess:
                  _activeAuthorizeCallbacks[txnId]?.onSendAuthorizedCompleted,
              onFailure:
                  _activeAuthorizeCallbacks[txnId]?.onSendTransactionFailure,
              onTerminalComplete: () => _activeAuthorizeCallbacks.remove(txnId),
            );
            break;
          case 'refundEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activeRefundCallbacks[txnId],
              onSuccess:
                  _activeRefundCallbacks[txnId]?.onTransactionRefundCompleted,
              onFailure:
                  _activeRefundCallbacks[txnId]?.onSendTransactionFailure,
              onTerminalComplete: () => _activeRefundCallbacks.remove(txnId),
            );
            break;
          case 'openRefundEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activeOpenRefundCallbacks[txnId],
              onSuccess: _activeOpenRefundCallbacks[txnId]
                  ?.onTransactionOpenRefundCompleted,
              onFailure:
                  _activeOpenRefundCallbacks[txnId]?.onSendTransactionFailure,
              onTerminalComplete: () =>
                  _activeOpenRefundCallbacks.remove(txnId),
            );
            break;
          case 'purchaseVoidEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activePurchaseVoidCallbacks[txnId],
              onSuccess: _activePurchaseVoidCallbacks[txnId]
                  ?.onSendPurchaseVoidCompleted,
              onFailure: _activePurchaseVoidCallbacks[txnId]
                  ?.onSendPurchaseVoidFailure,
              onTerminalComplete: () =>
                  _activePurchaseVoidCallbacks.remove(txnId),
            );
            break;
          case 'captureAuthorizationWithTapEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks:
                  _activeCaptureAuthorizationWithTapCallbacks[txnId],
              onSuccess: _activeCaptureAuthorizationWithTapCallbacks[txnId]
                  ?.onAuthorizedResponseWithTapCompleted,
              onFailure: _activeCaptureAuthorizationWithTapCallbacks[txnId]
                  ?.onSendTransactionFailure,
              onTerminalComplete: () =>
                  _activeCaptureAuthorizationWithTapCallbacks.remove(txnId),
            );
            break;
          case 'voidAuthorizationWithTapEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks:
                  _activeVoidAuthorizationWithTapCallbacks[txnId],
              onSuccess: _activeVoidAuthorizationWithTapCallbacks[txnId]
                  ?.onVoidAuthorizationWithTapCompleted,
              onFailure: _activeVoidAuthorizationWithTapCallbacks[txnId]
                  ?.onSendTransactionFailure,
              onTerminalComplete: () =>
                  _activeVoidAuthorizationWithTapCallbacks.remove(txnId),
            );
            break;
          case 'refundVoidEvent':
            _dispatchChannelEvent(
              txnId: txnId,
              eventType: eventType,
              message: message,
              data: data,
              registeredCallbacks: _activeRefundVoidCallbacks[txnId],
              onSuccess:
                  _activeRefundVoidCallbacks[txnId]?.onRefundVoidCompleted,
              onFailure: _activeRefundVoidCallbacks[txnId]?.onRefundVoidFailure,
              onTerminalComplete: () =>
                  _activeRefundVoidCallbacks.remove(txnId),
            );
            break;
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('TerminalModel event error (${call.method}): $e\n$st');
      }
    }
  }

  bool _ownsTransaction(String method, String txnId) {
    switch (method) {
      case 'purchaseEvent':
        return _activePurchaseCallbacks.containsKey(txnId);
      case 'RoutingLookupEvent':
        return _activeRoutingLookupCallbacks.containsKey(txnId);
      case 'purchaseWithQREvent':
        return _activePurchaseWithQRCallbacks.containsKey(txnId);
      case 'installmentsEvent':
        return _activeInstallmentsCallbacks.containsKey(txnId);
      case 'purchaseWithTipEvent':
        return _activePurchaseWithTipCallbacks.containsKey(txnId);
      case 'authorizeEvent':
      case 'authEvent':
        return _activeAuthorizeCallbacks.containsKey(txnId);
      case 'refundEvent':
        return _activeRefundCallbacks.containsKey(txnId);
      case 'openRefundEvent':
        return _activeOpenRefundCallbacks.containsKey(txnId);
      case 'purchaseVoidEvent':
        return _activePurchaseVoidCallbacks.containsKey(txnId);
      case 'captureAuthorizationWithTapEvent':
        return _activeCaptureAuthorizationWithTapCallbacks.containsKey(txnId);
      case 'voidAuthorizationWithTapEvent':
        return _activeVoidAuthorizationWithTapCallbacks.containsKey(txnId);
      case 'refundVoidEvent':
        return _activeRefundVoidCallbacks.containsKey(txnId);
      default:
        return false;
    }
  }
}
