import 'package:flutter_terminal_sdk/domain/models/data/dto/routing_profile_terminal.dart';

class RoutingProfile {
  final String serialNumber;
  final List<RoutingProfileTerminal> terminals;

  RoutingProfile({
    required this.serialNumber,
    required this.terminals,
  });

  factory RoutingProfile.fromJson(Map<String, dynamic> json) {
    return RoutingProfile(
      serialNumber: json['serialNumber'],
      terminals: (json['terminals'] as List)
          .map((terminalJson) => RoutingProfileTerminal.fromJson(terminalJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'terminals': terminals.map((terminal) => terminal.toJson()).toList(),
    };
  }
}
