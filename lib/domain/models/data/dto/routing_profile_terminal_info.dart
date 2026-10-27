class RoutingProfileTerminalInfo {
  final String? bankName;
  final String? acquirerId;
  final String acquirerTerminalId;
  final String? virtualSerialNumber;

  RoutingProfileTerminalInfo({
    this.bankName,
    this.acquirerId,
    required this.acquirerTerminalId,
    this.virtualSerialNumber,
  });

  factory RoutingProfileTerminalInfo.fromJson(Map<String, dynamic> json) {
    return RoutingProfileTerminalInfo(
      bankName: json['bankName'],
      acquirerId: json['acquirerId'],
      acquirerTerminalId: json['acquirerTerminalId'],
      virtualSerialNumber: json['virtualSerialNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'acquirerId': acquirerId,
      'acquirerTerminalId': acquirerTerminalId,
      'virtualSerialNumber': virtualSerialNumber,
    };
  }
}
