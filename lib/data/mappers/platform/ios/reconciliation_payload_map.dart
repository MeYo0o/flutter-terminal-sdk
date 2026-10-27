import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap iosReconciliationOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'getReconciliation': (raw) => normalizeTypedPayload(raw),
  'getReconciliationList': (raw) => normalizeTypedPayload(raw),
  'getReconcileList': (raw) => normalizeTypedPayload(raw),
  'getReconcileDetails': (raw) => normalizeTypedPayload(raw),
  'reconcile': (raw) => normalizeTypedPayload(raw),
};
