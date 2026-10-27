import '../../../domain/models/data/reconcile_response.dart';
import '../../../domain/models/data/reconciliation_list_response.dart';
import '../../../domain/models/data/reconciliation_receipts_response.dart';
import '../../mappers/native/reconciliation_mapper.dart';
import 'adapter_utils.dart';

ReconciliationResponse adaptReconciliationResult(
        String operation, Object? data) =>
    mapReconciliationResponse(unwrapForCurrentPlatform(operation, data));

ReconciliationListResponse adaptReconciliationListResult(
        String operation, Object? data) =>
    mapReconciliationListResponse(unwrapForCurrentPlatform(operation, data));

ReconciliationReceiptsResponse adaptReconciliationReceiptsResult(
        String operation, Object? data) =>
    mapReconciliationReceiptsResponse(
        unwrapForCurrentPlatform(operation, data));
