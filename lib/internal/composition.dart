import '../data/sources/native/method_channel_native_source.dart';
import '../domain/ports/nearpay_native_port.dart';
import '../domain/operations/bridge_operations.dart';

class BridgeComposition {
  BridgeComposition({
    required this.port,
    required this.operations,
  });

  final NearpayNativePort port;
  final BridgeOperations operations;
}

BridgeComposition createBridgeComposition({
  required bool Function() isInitialized,
  NearpayNativePort? port,
}) {
  final resolvedPort = port ?? MethodChannelNativeSource.instance;
  return BridgeComposition(
    port: resolvedPort,
    operations: BridgeOperations(
      port: resolvedPort,
      isInitialized: isInitialized,
    ),
  );
}
