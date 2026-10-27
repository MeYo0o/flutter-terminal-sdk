import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap iosIntentOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'getIntent': (raw) => normalizeTypedPayload(raw),
  'getIntentDetails': (raw) => normalizeTypedPayload(raw),
  'getIntentList': (raw) => normalizeTypedPayload(raw),
  'getRoutingProfile': (raw) => normalizeTypedPayload(raw),
};
