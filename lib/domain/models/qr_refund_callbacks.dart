import '../../errors/errors.dart';
import 'data/generated_qr_code.dart';
import 'data/qr_status_response.dart';

class QrRefundCallbacks {
  final void Function(GeneratedQRCode qrCode)? onQrRefundQrCodeGenerated;
  final void Function(GeneratedQRCode qrCode)? onQrUiPresented;
  final void Function()? onUiClosed;
  final void Function(QrStatusResponse status)? onQrRefundSuccess;
  final void Function(NearpayException error)? onQrRefundFailure;
  final void Function(NearpayException error)? onNearpayException;

  QrRefundCallbacks({
    this.onQrRefundQrCodeGenerated,
    this.onQrUiPresented,
    this.onUiClosed,
    this.onQrRefundSuccess,
    this.onQrRefundFailure,
    this.onNearpayException,
  });
}
