import 'callbacks.dart';
import 'card_reader_callbacks.dart';

class PurchaseWithQrCallbacks {
  final TransactionPurchaseWithQRCallback? onQrPaymentApproved;
  final TransactionPurchaseWithQRCallback? onQrPaymentDeclined;
  final StringCallback? onQrPaymentFailure;
  final QRStatusCallback? onQrPaymentStatusCompleted;
  final QRStatusCallback? onQrPaymentStatusExpired;
  final QRStatusCallback? onQrPaymentStatusFailed;
  final QRStatusCallback? onQrPaymentStatusUpdated;
  final QRGeneratedCallback? onQrUiPresented;
  final StringCallback? onParsingFailed;
  final VoidCallback? onQrUiClosed;

  PurchaseWithQrCallbacks({
    this.onQrPaymentApproved,
    this.onQrPaymentDeclined,
    this.onQrPaymentFailure,
    this.onQrPaymentStatusCompleted,
    this.onQrPaymentStatusExpired,
    this.onQrPaymentStatusFailed,
    this.onQrPaymentStatusUpdated,
    this.onQrUiPresented,
    this.onParsingFailed,
    this.onQrUiClosed,
  });
}
