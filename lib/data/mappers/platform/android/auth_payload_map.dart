import '../native_payload_map.dart';
import '../normalizer.dart';

final NativeOperationPayloadMap androidAuthOperationPayloadMap =
    <String, NativeOperationPayloadHandler>{
  'sendMobileOtp': (raw) => normalizeTypedPayload(raw),
  'sendEmailOtp': (raw) => normalizeTypedPayload(raw),
  'verifyMobileOtp': (raw) => normalizeTypedPayload(raw),
  'verifyEmailOtp': (raw) => normalizeTypedPayload(raw),
  'jwtVerify': (raw) => normalizeTypedPayload(raw),
  'getUser': (raw) => normalizeTypedPayload(raw),
  'getUsers': (raw) => normalizeTypedPayload(raw),
  'getTerminal': (raw) => normalizeTypedPayload(raw),
  'getTerminalList': (raw) => normalizeTypedPayload(raw),
  'connectTerminal': (raw) => normalizeTypedPayload(raw),
  'checkRequiredPermissions': (raw) => normalizeTypedPayload(raw),
};
