import 'package:flutter_terminal_sdk/domain/models/data/dto/routing_response.dart';

class RoutingFullResponse {
  final RoutingResponse? routingResponse;
  final String? routingSessionId;

  RoutingFullResponse({
    this.routingResponse,
    this.routingSessionId,
  });

  factory RoutingFullResponse.fromJson(Map<dynamic, dynamic> json) {
    return RoutingFullResponse(
      routingResponse: json['response'] != null
          ? RoutingResponse.fromJson(json['response'])
          : null,
      routingSessionId: json['sessionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': routingResponse?.toJson(),
      'sessionId': routingSessionId,
    };
  }
}
