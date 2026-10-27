const List<String> kTerminalOperationNames = <String>[
  'purchase',
  'purchaseWithTip',
  'purchaseWithTokenization',
  'purchaseVoid',
  'installments',
  'authorize',
  'refund',
  'refundWithoutTap',
  'refundVoid',
  'openRefund',
  'incrementAuthorization',
  'captureAuthorization',
  'captureAuthorizationWithTap',
  'voidAuthorization',
  'voidAuthorizationWithTap',
  'tipTransaction',
  'reverseTransaction',
  'reconcile',
  'batchCapture',
  'cancelTransaction',
  'routingLookup',
  'routingExecute',
  'routingInstallments',
  'generateQrCode',
  'qrStatus',
  'qrRefund',
  'qrVoid',
];

const Map<String, String> kTerminalOperationAliases = <String, String>{
  'increment': 'incrementAuthorization',
  'capture': 'captureAuthorization',
  'tip': 'tipTransaction',
  'void': 'voidAuthorization',
  'reverse': 'reverseTransaction',
};

String canonicalTerminalOperationName(String value) {
  final trimmed = value.trim();
  return kTerminalOperationAliases[trimmed] ?? trimmed;
}
