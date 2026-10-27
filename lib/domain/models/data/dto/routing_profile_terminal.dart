import 'package:flutter_terminal_sdk/domain/models/data/dto/routing_profile_merchant_data.dart';
import 'package:flutter_terminal_sdk/domain/models/data/dto/routing_profile_terminal_info.dart';

class RoutingProfileTerminal {
  final RoutingProfileTerminalInfo terminalInfo;
  final RoutingProfileMerchantData merchantData;

  RoutingProfileTerminal({
    required this.terminalInfo,
    required this.merchantData,
  });

  factory RoutingProfileTerminal.fromJson(Map<String, dynamic> json) {
    return RoutingProfileTerminal(
      terminalInfo: RoutingProfileTerminalInfo.fromJson(json['terminalInfo']),
      merchantData: RoutingProfileMerchantData.fromJson(json['merchantData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terminalInfo': terminalInfo.toJson(),
      'merchantData': merchantData.toJson(),
    };
  }
}
