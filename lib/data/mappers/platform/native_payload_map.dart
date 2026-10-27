/// A handler that normalizes the raw native payload for a single operation.
///
/// Mirrors RN's `NativeOperationPayloadHandler`.
typedef NativeOperationPayloadHandler = Object? Function(Object? raw);

typedef NativeOperationPayloadMap = Map<String, NativeOperationPayloadHandler>;
