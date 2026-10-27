import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap androidAuthorizeOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'authorizeEvent': (raw) => normalizeTypedPayload(raw),
  'captureAuthorizationWithTapEvent': (raw) => normalizeTypedPayload(raw),
  'voidAuthorizationWithTap': (raw) => normalizeTypedPayload(raw),
  'voidAuthorizationWithTapEvent': (raw) => normalizeTypedPayload(raw),
  'voidAuthorization': (raw) => normalizeTypedPayload(raw),
  'incrementAuthorization': (raw) => normalizeTypedPayload(raw),
  'captureAuthorization': (raw) => normalizeTypedPayload(raw),
};
