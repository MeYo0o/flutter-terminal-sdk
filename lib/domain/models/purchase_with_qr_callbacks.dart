import '../../errors/errors.dart';
import 'callbacks.dart';

class PurchaseWithQrCallbacks {
  final TransactionPurchaseWithQRCallback? onQrPaymentApproved;
  final TransactionPurchaseWithQRCallback? onQrPaymentDeclined;
  final void Function(NearpayException error)? onNearpayException;
  final QRStatusCallback? onQrPaymentStatusCompleted;
  final QRStatusCallback? onQrPaymentStatusExpired;
  final QRStatusCallback? onQrPaymentStatusCancelled;
  final QRStatusCallback? onQrPaymentStatusFailed;
  final QRStatusCallback? onQrPaymentStatusUpdated;
  final QRGeneratedCallback? onQrUiPresented;
  final VoidCallback? onUiClosed;

  PurchaseWithQrCallbacks({
    this.onQrPaymentApproved,
    this.onQrPaymentDeclined,
    this.onNearpayException,
    this.onQrPaymentStatusCompleted,
    this.onQrPaymentStatusExpired,
    this.onQrPaymentStatusCancelled,
    this.onQrPaymentStatusFailed,
    this.onQrPaymentStatusUpdated,
    this.onQrUiPresented,
    this.onUiClosed,
  });
}
