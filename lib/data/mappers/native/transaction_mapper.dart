import '../../../domain/models/data/dto/routing_full_response.dart';
import '../../../domain/models/data/intent_response_turkey.dart';
import '../../../domain/models/data/purchase_response.dart';
import '../../../domain/models/data/refund_response.dart';
import '../../../domain/models/data/reverse_response.dart';
import 'mapper_utils.dart';

PurchaseResponse mapPurchaseResponse(Object? raw) =>
    PurchaseResponse.fromJson(asResponseMap(raw));

RefundResponse mapRefundResponse(Object? raw) =>
    RefundResponse.fromJson(asResponseMap(raw));

ReverseResponse mapReverseResponse(Object? raw) =>
    ReverseResponse.fromJson(asResponseMap(raw));

RoutingFullResponse mapRoutingFullResponse(Object? raw) =>
    RoutingFullResponse.fromJson(asResponseMap(raw));

IntentResponseTurkey mapIntentResponseTurkey(Object? raw) =>
    IntentResponseTurkey.fromJson(asResponseMap(raw));
