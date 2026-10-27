class GeneratedQRCode {
  final String qrCode;
  final String transactionId;
  final String amount;

  const GeneratedQRCode({
    required this.qrCode,
    required this.transactionId,
    required this.amount,
  });

  factory GeneratedQRCode.fromJson(dynamic json) {
    return GeneratedQRCode(
      qrCode: json['qrCode'] as String,
      transactionId: json['transactionId'] as String,
      amount: json['amount'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'qrCode': qrCode,
        'transactionId': transactionId,
        'amount': amount,
      };

  @override
  String toString() =>
      'GeneratedQRCode(qrCode: $qrCode, transactionId: $transactionId, amount: $amount)';
}
