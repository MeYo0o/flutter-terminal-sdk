import 'key_normalizer.dart';
import 'native_payload_map.dart';

Object? normalizePayload(Object? raw) => normalizeNativePayloadKeys(raw);

Object? normalizeTypedPayload(Object? raw) => raw;

NativeOperationPayloadMap mergeOperationPayloadMaps(
  List<NativeOperationPayloadMap> maps,
) {
  final merged = <String, NativeOperationPayloadHandler>{};
  for (final map in maps) {
    map.forEach((operation, handler) {
      if (merged.containsKey(operation)) {
        throw StateError(
            'Duplicate native operation payload mapper for "$operation"');
      }
      merged[operation] = handler;
    });
  }
  return merged;
}
