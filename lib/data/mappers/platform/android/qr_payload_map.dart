import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap androidQrOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'qrUiPresented': (raw) => normalizeTypedPayload(raw),
  'qrPaymentStatusUpdated': (raw) => normalizeTypedPayload(raw),
  'qrPaymentStatusExpired': (raw) => normalizeTypedPayload(raw),
  'qrPaymentStatusCompleted': (raw) => normalizeTypedPayload(raw),
  'qrPaymentApproved': (raw) => normalizeTypedPayload(raw),
  'qrPaymentDeclined': (raw) => normalizeTypedPayload(raw),
  'qrPaymentStatusFailed': (raw) => normalizeTypedPayload(raw),
  'generateQrCode': (raw) => normalizeTypedPayload(raw),
  'qrStatus': (raw) => normalizeTypedPayload(raw),
  'qrVoid': (raw) => normalizeTypedPayload(raw),
  'qrVoidEvent': (raw) => normalizeTypedPayload(raw),
  'qrRefund': (raw) => normalizeTypedPayload(raw),
  'qrRefundEvent': (raw) => normalizeTypedPayload(raw),
};
