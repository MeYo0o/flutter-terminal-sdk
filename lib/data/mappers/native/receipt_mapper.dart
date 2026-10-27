import 'dart:convert';
import 'dart:typed_data';

Uint8List mapReceiptImage(Object? raw) {
  if (raw is Uint8List) {
    return raw;
  }
  if (raw is List) {
    return Uint8List.fromList(raw.cast<int>());
  }
  if (raw is String) {
    return base64Decode(raw);
  }
  throw StateError("Unexpected data type for image: ${raw.runtimeType}");
}
