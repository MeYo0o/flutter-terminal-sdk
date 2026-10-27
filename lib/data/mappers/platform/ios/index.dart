import '../native_payload_map.dart';
import '../normalizer.dart';
import 'auth_payload_map.dart';
import 'authorize_payload_map.dart';
import 'intent_payload_map.dart';
import 'operation_payload_map.dart';
import 'qr_payload_map.dart';
import 'reconciliation_payload_map.dart';
import 'terminal_config_payload_map.dart';
import 'transaction_payload_map.dart';

final NativeOperationPayloadMap iosOperationPayloadMap =
    mergeOperationPayloadMaps([
  iosAuthOperationPayloadMap,
  iosTerminalConfigOperationPayloadMap,
  iosIntentOperationPayloadMap,
  iosReconciliationOperationPayloadMap,
  iosTransactionOperationPayloadMap,
  iosAuthorizeOperationPayloadMap,
  iosQrOperationPayloadMap,
  iosOperationOperationPayloadMap,
]);
