part of 'terminal_response.dart';

extension TerminalModelEventDispatch on TerminalModel {
  CardReaderCallbacks? _cardReaderCallbacksFrom(dynamic callbacks) {
    if (callbacks is PurchaseCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is RoutingLookupCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is AuthorizedCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is RefundCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is OpenRefundCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is PurchaseVoidCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is RefundVoidCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is CaptureAuthorizationWithTapCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    if (callbacks is VoidAuthorizationWithTapCallbacks) {
      return callbacks.cardReaderCallbacks;
    }
    return null;
  }

  LinkingCallbacks? _linkingCallbacksFrom(dynamic callbacks) {
    if (callbacks is PurchaseCallbacks) {
      return callbacks.linkingCallbacks;
    }
    if (callbacks is AuthorizedCallbacks) {
      return callbacks.linkingCallbacks;
    }
    if (callbacks is RefundCallbacks) {
      return callbacks.linkingCallbacks;
    }
    if (callbacks is OpenRefundCallbacks) {
      return callbacks.linkingCallbacks;
    }
    if (callbacks is PurchaseVoidCallbacks) {
      return callbacks.linkingCallbacks;
    }
    if (callbacks is RefundVoidCallbacks) {
      return callbacks.linkingCallbacks;
    }
    if (callbacks is CaptureAuthorizationWithTapCallbacks) {
      return callbacks.linkingCallbacks;
    }
    if (callbacks is VoidAuthorizationWithTapCallbacks) {
      return callbacks.linkingCallbacks;
    }
    return null;
  }

  CardReaderCallbacks? _lookupCardReaderCallbacks(String txnId) {
    return _activePurchaseCallbacks[txnId]?.cardReaderCallbacks ??
        _activePurchaseVoidCallbacks[txnId]?.cardReaderCallbacks ??
        _activeRefundCallbacks[txnId]?.cardReaderCallbacks ??
        _activeRefundVoidCallbacks[txnId]?.cardReaderCallbacks ??
        _activeAuthorizeCallbacks[txnId]?.cardReaderCallbacks ??
        _activePurchaseWithTipCallbacks[txnId]?.cardReaderCallbacks ??
        _activeInstallmentsCallbacks[txnId]?.cardReaderCallbacks ??
        _activeOpenRefundCallbacks[txnId]?.cardReaderCallbacks ??
        _activeCaptureAuthorizationWithTapCallbacks[txnId]
            ?.cardReaderCallbacks ??
        _activeVoidAuthorizationWithTapCallbacks[txnId]?.cardReaderCallbacks ??
        _activeRoutingLookupCallbacks[txnId]?.cardReaderCallbacks;
  }

  LinkingCallbacks? _lookupLinkingCallbacks(String txnId) {
    return _activePurchaseVoidCallbacks[txnId]?.linkingCallbacks ??
        _activeRefundVoidCallbacks[txnId]?.linkingCallbacks ??
        _activePurchaseCallbacks[txnId]?.linkingCallbacks ??
        _activeRefundCallbacks[txnId]?.linkingCallbacks ??
        _activeAuthorizeCallbacks[txnId]?.linkingCallbacks ??
        _activePurchaseWithTipCallbacks[txnId]?.linkingCallbacks ??
        _activeInstallmentsCallbacks[txnId]?.linkingCallbacks ??
        _activeOpenRefundCallbacks[txnId]?.linkingCallbacks ??
        _activeCaptureAuthorizationWithTapCallbacks[txnId]?.linkingCallbacks ??
        _activeVoidAuthorizationWithTapCallbacks[txnId]?.linkingCallbacks;
  }

  void _handleEvent(
    String eventType,
    String? message,
    Map<String, dynamic>? data, {
    CardReaderCallbacks? cardReaderCallbacks,
    LinkingCallbacks? linkingCallbacks,
    Function? onSuccess,
    Function(String)? onFailure,
    void Function()? onTerminalComplete,
  }) {
    void completeTerminal() => onTerminalComplete?.call();

    if (isLinkingEventType(eventType)) {
      dispatchLinkingCallbacks(
        linkingCallbacks,
        type: eventType,
        message: message,
        data: data,
      );
      return;
    }

    final type = isTerminalResultEventType(eventType)
        ? eventType
        : normalizeCardReaderEventType(eventType);

    switch (type) {
      case 'readerDisplayed':
        cardReaderCallbacks?.onReaderDisplayed?.call();
        break;
      case 'readerDismissed':
        cardReaderCallbacks?.onReaderDismissed?.call();
        break;
      case 'readerClosed':
        cardReaderCallbacks?.onReaderClosed?.call();
        break;
      case 'readingStarted':
        cardReaderCallbacks?.onReadingStarted?.call();
        break;
      case 'readerWaiting':
        cardReaderCallbacks?.onReaderWaiting?.call();
        break;
      case 'readerReading':
        cardReaderCallbacks?.onReaderReading?.call();
        break;
      case 'readerRetry':
        cardReaderCallbacks?.onReaderRetry?.call();
        break;
      case 'pinEntering':
        cardReaderCallbacks?.onPinEntering?.call();
        break;
      case 'readerFinished':
        cardReaderCallbacks?.onReaderFinished?.call();
        break;
      case 'readerError':
        {
          final errorMessage = (message != null && message.trim().isNotEmpty)
              ? message
              : (eventType == 'linkingFailure'
                  ? 'Linking failed'
                  : 'Reader error');
          cardReaderCallbacks?.onReaderError?.call(errorMessage);
        }
        break;
      case 'cardReadSuccess':
        cardReaderCallbacks?.onCardReadSuccess?.call();
        break;
      case 'cardReadFailure':
        if (message != null) {
          cardReaderCallbacks?.onCardReadFailure?.call(message);
        }
        break;
      case 'sendTransactionFailure':
        if (message != null) {
          onFailure?.call(message);
        }
        completeTerminal();
        break;
      case 'authorizeFailure':
        if (message != null) {
          onFailure?.call(message);
        }
        completeTerminal();
        break;
      case 'routingLookupFailure':
        if (message != null) {
          onFailure?.call(message);
        }
        completeTerminal();
        break;
      case 'onSendTransactionCompleted':
        if (data != null) {
          try {
            final purchaseResponse = adaptPurchaseResult('purchaseEvent', data);
            onSuccess?.call(purchaseResponse);
          } catch (e) {
            onFailure?.call("Error parsing PurchaseResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'sendPurchaseTransactionCompleted':
        if (data != null) {
          try {
            final purchaseResponse = adaptPurchaseResult('purchaseEvent', data);
            onSuccess?.call(purchaseResponse);
          } catch (e) {
            onFailure?.call("Error parsing PurchaseResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'routingLookupCompleted':
        if (kDebugMode) {
          debugPrint("routingLookupCompleted $data");
        }
        if (data != null) {
          if (kDebugMode) {
            debugPrint("Routing lookup data: $data");
          }
          try {
            final routingResponse =
                adaptRoutingFullResult('RoutingLookupEvent', data);
            onSuccess?.call(routingResponse);
          } catch (e) {
            onFailure?.call("Error parsing RoutingResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'sendPurchaseWithTipTransactionCompleted':
        if (data != null) {
          try {
            final purchaseResponse =
                adaptPurchaseResult('purchaseWithTipEvent', data);
            onSuccess?.call(purchaseResponse);
          } catch (e) {
            onFailure?.call("Error parsing PurchaseResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'sendInstallmentsTransactionCompleted':
        if (data != null) {
          try {
            final purchaseResponse =
                adaptPurchaseResult('installmentsEvent', data);
            onSuccess?.call(purchaseResponse);
          } catch (e) {
            onFailure?.call("Error parsing PurchaseResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'sendRefundTransactionCompleted':
        if (data != null) {
          try {
            final refundResponse = adaptRefundResult('refundEvent', data);
            onSuccess?.call(refundResponse);
          } catch (e) {
            onFailure?.call("Error parsing RefundResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'sendOpenRefundTransactionCompleted':
        if (data != null) {
          try {
            final refundResponse = adaptRefundResult('openRefundEvent', data);
            onSuccess?.call(refundResponse);
          } catch (e) {
            onFailure?.call("Error parsing RefundResponse: $e");
          }
        }
        completeTerminal();
        break;

      case 'authorizeSuccess':
      case 'authorizeCompleted':
        if (data != null) {
          try {
            final authorizeResponse =
                adaptAuthorizeResult('authorizeEvent', data);
            onSuccess?.call(authorizeResponse);
          } catch (e) {
            onFailure?.call("Error parsing AuthorizeResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'captureWithTapCompleted':
        if (data != null) {
          try {
            final captureResponse =
                adaptCaptureResult('captureAuthorizationWithTapEvent', data);
            onSuccess?.call(captureResponse);
          } catch (e) {
            onFailure?.call("Error parsing AuthorizeResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'voidWithTapCompleted':
        if (data != null) {
          try {
            final voidResponse = adaptVoidAuthorizationResult(
                'voidAuthorizationWithTapEvent', data);
            onSuccess?.call(voidResponse);
          } catch (e) {
            onFailure?.call("Error parsing VoidAuthorizationResponse: $e");
          }
        }
        completeTerminal();
        break;
      case 'sendTransactionVoidCompleted':
        if (data != null) {
          try {
            final intentResponseTurkey =
                adaptIntentResponseTurkeyResult('purchaseVoidEvent', data);
            onSuccess?.call(intentResponseTurkey);
          } catch (e) {
            onFailure?.call("Error parsing IntentResponseTurkey: $e");
          }
        }
        completeTerminal();
        break;
      default:
        if (kDebugMode) {
          debugPrint("Ignoring unhandled event type: $eventType");
        }
        break;
    }
  }
}
