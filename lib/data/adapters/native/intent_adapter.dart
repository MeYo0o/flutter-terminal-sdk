import '../../../domain/models/data/intent_details.dart';
import '../../../domain/models/data/dto/routing_profile.dart';
import '../../../domain/models/intents_list_response.dart';
import '../../mappers/native/intent_mapper.dart';
import 'adapter_utils.dart';

IntentDetails adaptIntentDetailsResult(String operation, Object? data) =>
    mapIntentDetails(unwrapForCurrentPlatform(operation, data));

IntentsListResponse adaptIntentsListResult(String operation, Object? data) =>
    mapIntentsListResponse(unwrapForCurrentPlatform(operation, data));

RoutingProfile adaptRoutingProfileResult(String operation, Object? data) =>
    mapRoutingProfile(unwrapForCurrentPlatform(operation, data));
