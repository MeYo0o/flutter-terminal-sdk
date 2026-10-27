import '../../../domain/models/data/dto/routing_full_response.dart';
import '../../../domain/models/data/intent_response_turkey.dart';
import '../../../domain/models/data/purchase_response.dart';
import '../../../domain/models/data/refund_response.dart';
import '../../../domain/models/data/reverse_response.dart';
import '../../mappers/native/transaction_mapper.dart';
import 'adapter_utils.dart';

PurchaseResponse adaptPurchaseResult(String operation, Object? data) =>
    mapPurchaseResponse(unwrapForCurrentPlatform(operation, data));

RefundResponse adaptRefundResult(String operation, Object? data) =>
    mapRefundResponse(unwrapForCurrentPlatform(operation, data));

ReverseResponse adaptReverseResult(String operation, Object? data) =>
    mapReverseResponse(unwrapForCurrentPlatform(operation, data));

RoutingFullResponse adaptRoutingFullResult(String operation, Object? data) =>
    mapRoutingFullResponse(unwrapForCurrentPlatform(operation, data));

IntentResponseTurkey adaptIntentResponseTurkeyResult(
        String operation, Object? data) =>
    mapIntentResponseTurkey(unwrapForCurrentPlatform(operation, data));
