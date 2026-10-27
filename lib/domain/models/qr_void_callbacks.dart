import '../../errors/errors.dart';
import 'data/generated_qr_code.dart';
import 'data/qr_status_response.dart';

class QrVoidCallbacks {
  final void Function(GeneratedQRCode qrCode)? onQrVoidQrCodeGenerated;
  final void Function(GeneratedQRCode qrCode)? onQrUiPresented;
  final void Function()? onUiClosed;
  final void Function(QrStatusResponse status)? onQrVoidSuccess;
  final void Function(NearpayException error)? onQrVoidFailure;
  final void Function(NearpayException error)? onNearpayException;

  QrVoidCallbacks({
    this.onQrVoidQrCodeGenerated,
    this.onQrUiPresented,
    this.onUiClosed,
    this.onQrVoidSuccess,
    this.onQrVoidFailure,
    this.onNearpayException,
  });
}
