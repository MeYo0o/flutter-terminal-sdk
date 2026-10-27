import '../../../helper/platform_support.dart';

Map<String, dynamic> buildRefundChannelPayload({
  required String? terminalUUID,
  required String newRefundIntentUUID,
  required String originalIntentUUID,
  required int amount,
  String? customerReferenceNumber,
  String? scheme,
  String? refundRRN,
  double? timestamp,
}) {
  final channelIntentUUID =
      isAndroidPlatform ? originalIntentUUID : newRefundIntentUUID;
  final channelRefundUUID =
      isAndroidPlatform ? newRefundIntentUUID : originalIntentUUID;

  return {
    'terminalUUID': terminalUUID,
    'intentUUID': channelIntentUUID,
    'intentUuid': channelIntentUUID,
    'refundUUID': channelRefundUUID,
    'refundUuid': channelRefundUUID,
    'amount': amount,
    if (customerReferenceNumber != null)
      'customerReferenceNumber': customerReferenceNumber,
    if (scheme != null) 'scheme': scheme,
    if (refundRRN != null && refundRRN.isNotEmpty) 'refundRRN': refundRRN,
    if (timestamp != null) 'timestamp': timestamp,
  };
}
