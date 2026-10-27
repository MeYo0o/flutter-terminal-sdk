import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap androidTransactionOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'purchaseEvent': (raw) => normalizeTypedPayload(raw),
  'refundEvent': (raw) => normalizeTypedPayload(raw),
  'openRefundEvent': (raw) => normalizeTypedPayload(raw),
  'purchaseWithTipEvent': (raw) => normalizeTypedPayload(raw),
  'installmentsEvent': (raw) => normalizeTypedPayload(raw),
  'purchaseVoidEvent': (raw) => normalizeTypedPayload(raw),
  'refundVoidEvent': (raw) => normalizeTypedPayload(raw),
  'RoutingLookupEvent': (raw) => normalizeTypedPayload(raw),
  'reverseTransaction': (raw) => normalizeTypedPayload(raw),
  'tipTransaction': (raw) => normalizeTypedPayload(raw),
  'routingExecute': (raw) => normalizeTypedPayload(raw),
  'routingInstallments': (raw) => normalizeTypedPayload(raw),
};
