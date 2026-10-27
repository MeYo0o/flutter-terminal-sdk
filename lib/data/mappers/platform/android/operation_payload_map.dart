import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap androidOperationOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'createProxyRoom': (raw) => normalizeTypedPayload(raw),
};
