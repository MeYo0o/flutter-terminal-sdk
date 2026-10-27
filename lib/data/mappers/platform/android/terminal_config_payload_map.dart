import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap androidTerminalConfigOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'getTerminalConfig': (raw) => normalizeTypedPayload(raw),
};
