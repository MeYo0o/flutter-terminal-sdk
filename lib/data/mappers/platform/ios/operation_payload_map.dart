import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap iosOperationOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'createProxyRoom': (raw) => normalizeTypedPayload(raw),
};
