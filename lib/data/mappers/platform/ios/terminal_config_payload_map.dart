import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap iosTerminalConfigOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'getTerminalConfig': (raw) => normalizeTypedPayload(raw),
};
