import '../../../domain/models/data/reconcile_response.dart';
import '../../../domain/models/data/reconciliation_list_response.dart';
import '../../../domain/models/data/reconciliation_receipts_response.dart';
import 'mapper_utils.dart';

ReconciliationResponse mapReconciliationResponse(Object? raw) =>
    ReconciliationResponse.fromJson(asResponseMap(raw));

ReconciliationListResponse mapReconciliationListResponse(Object? raw) =>
    ReconciliationListResponse.fromJson(asResponseMap(raw));

ReconciliationReceiptsResponse mapReconciliationReceiptsResponse(Object? raw) =>
    ReconciliationReceiptsResponse.fromJson(asResponseMap(raw));
