import '../../helper/platform_support.dart';

const Map<String, String> kIosUnavailableOperations = <String, String>{
  'shareInvoice': 'shareInvoice is only available on Android',
  'shareReceiptViaNfc': 'shareReceiptViaNfc is only available on Android',
  'startShareUrlService': 'startShareUrlService is only available on Android',
  'stopReceiptViaNfcShare': 'stopReceiptViaNfcShare is only available on Android',
  'supportsReceiptViaNfc': 'supportsReceiptViaNfc is only available on Android',
  'createProxyRoom': 'createProxyRoom is only available on Android',
  'getUsers': 'iOS getUsers is not available',
  'toImage': 'iOS toImage is not available',
  'printMadaReceipt': 'iOS printMadaReceipt is not available',
};

const Map<String, String> kAndroidUnavailableOperations = <String, String>{
  'authenticator': 'authenticator is only available on iOS',
  'getProduct': 'getProduct is only available on iOS',
};

void requireOperationSupported(String operation) {
  final iosMessage = kIosUnavailableOperations[operation];
  if (iosMessage != null) {
    requireAndroidFeature(iosMessage);
  }
  final androidMessage = kAndroidUnavailableOperations[operation];
  if (androidMessage != null) {
    requireIosFeature(androidMessage);
  }
}
