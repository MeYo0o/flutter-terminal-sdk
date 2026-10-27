import 'package:flutter_terminal_sdk/domain/models/data/dto/routing_bin.dart';

class RoutingResponse {
  final RoutingBin? binInformation;

  RoutingResponse({
    this.binInformation,
  });

  factory RoutingResponse.fromJson(Map<dynamic, dynamic> json) {
    return RoutingResponse(
      binInformation: json['binInformation'] != null
          ? RoutingBin.fromJson(json['binInformation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'binInformation': binInformation?.toJson(),
    };
  }
}
