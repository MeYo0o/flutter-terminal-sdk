import '../mappers/platform/normalizer.dart';
import '../mappers/platform/resolver.dart';

Object? unwrapNativePayload(
  String operation,
  Object? data, {
  required bool isIOS,
}) {
  final handler = resolveNativePayloadMapper(isIOS)[operation];
  if (handler != null) {
    return handler(data);
  }
  return normalizeTypedPayload(data);
}
