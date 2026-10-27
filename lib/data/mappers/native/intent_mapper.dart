import '../../../domain/models/data/intent_details.dart';
import '../../../domain/models/data/dto/routing_profile.dart';
import '../../../domain/models/intents_list_response.dart';
import 'mapper_utils.dart';

IntentDetails mapIntentDetails(Object? raw) =>
    IntentDetails.fromJson(asResponseMap(raw));

IntentsListResponse mapIntentsListResponse(Object? raw) =>
    IntentsListResponse.fromJson(asResponseMap(raw));

RoutingProfile mapRoutingProfile(Object? raw) =>
    RoutingProfile.fromJson(asResponseMap(raw));
