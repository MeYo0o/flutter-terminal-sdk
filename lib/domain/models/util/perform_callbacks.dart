import 'dart:async';

import '../../../errors/errors.dart';
import '../authorized_callbacks.dart';
import '../capture_authorization_with_tap_callbacks.dart';
import '../data/authorize_response.dart';
import '../data/capture_response.dart';
import '../data/intent_response_turkey.dart';
import '../data/purchase_response.dart';
import '../data/refund_response.dart';
import '../data/void_authorization_response.dart';
import '../open_refund_callbacks.dart';
import '../purchase_callbacks.dart';
import '../purchase_void_callbacks.dart';
import '../refund_callbacks.dart';
import '../refund_void_callbacks.dart';
import '../void_authorization_with_tap_callbacks.dart';

void _failCompleter<T>(Completer<T> completer, String message) {
  if (!completer.isCompleted) {
    completer.completeError(NearpayException(message));
  }
}

void _completeCompleter<T>(Completer<T> completer, T value) {
  if (!completer.isCompleted) {
    completer.complete(value);
  }
}

PurchaseCallbacks wrapPurchaseCallbacks(
  PurchaseCallbacks original,
  Completer<PurchaseResponse> completer,
) {
  return PurchaseCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onSendTransactionFailure: (message) {
      original.onSendTransactionFailure?.call(message);
      _failCompleter(completer, message);
    },
    onTransactionPurchaseCompleted: (response) {
      original.onTransactionPurchaseCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}

RefundCallbacks wrapRefundCallbacks(
  RefundCallbacks original,
  Completer<RefundResponse> completer,
) {
  return RefundCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onSendTransactionFailure: (message) {
      original.onSendTransactionFailure?.call(message);
      _failCompleter(completer, message);
    },
    onTransactionRefundCompleted: (response) {
      original.onTransactionRefundCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}

OpenRefundCallbacks wrapOpenRefundCallbacks(
  OpenRefundCallbacks original,
  Completer<RefundResponse> completer,
) {
  return OpenRefundCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onSendTransactionFailure: (message) {
      original.onSendTransactionFailure?.call(message);
      _failCompleter(completer, message);
    },
    onTransactionOpenRefundCompleted: (response) {
      original.onTransactionOpenRefundCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}

AuthorizedCallbacks wrapAuthorizeCallbacks(
  AuthorizedCallbacks original,
  Completer<AuthorizeResponse> completer,
) {
  return AuthorizedCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onSendTransactionFailure: (message) {
      original.onSendTransactionFailure?.call(message);
      _failCompleter(completer, message);
    },
    onSendAuthorizedCompleted: (response) {
      original.onSendAuthorizedCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}

PurchaseVoidCallbacks wrapPurchaseVoidCallbacks(
  PurchaseVoidCallbacks original,
  Completer<IntentResponseTurkey> completer,
) {
  return PurchaseVoidCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onSendPurchaseVoidFailure: (message) {
      original.onSendPurchaseVoidFailure?.call(message);
      _failCompleter(completer, message);
    },
    onSendPurchaseVoidCompleted: (response) {
      original.onSendPurchaseVoidCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}

RefundVoidCallbacks wrapRefundVoidCallbacks(
  RefundVoidCallbacks original,
  Completer<IntentResponseTurkey> completer,
) {
  return RefundVoidCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onRefundVoidFailure: (message) {
      original.onRefundVoidFailure?.call(message);
      _failCompleter(completer, message);
    },
    onRefundVoidCompleted: (response) {
      original.onRefundVoidCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}

CaptureAuthorizationWithTapCallbacks wrapCaptureWithTapCallbacks(
  CaptureAuthorizationWithTapCallbacks original,
  Completer<CaptureResponse> completer,
) {
  return CaptureAuthorizationWithTapCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onSendTransactionFailure: (message) {
      original.onSendTransactionFailure?.call(message);
      _failCompleter(completer, message);
    },
    onAuthorizedResponseWithTapCompleted: (response) {
      original.onAuthorizedResponseWithTapCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}

VoidAuthorizationWithTapCallbacks wrapVoidAuthorizationWithTapCallbacks(
  VoidAuthorizationWithTapCallbacks original,
  Completer<VoidAuthorizationResponse> completer,
) {
  return VoidAuthorizationWithTapCallbacks(
    cardReaderCallbacks: original.cardReaderCallbacks,
    linkingCallbacks: original.linkingCallbacks,
    onSendTransactionFailure: (message) {
      original.onSendTransactionFailure?.call(message);
      _failCompleter(completer, message);
    },
    onVoidAuthorizationWithTapCompleted: (response) {
      original.onVoidAuthorizationWithTapCompleted?.call(response);
      _completeCompleter(completer, response);
    },
  );
}
