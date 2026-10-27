part of 'terminal_response.dart';

extension TerminalModelCashierOps on TerminalModel {
  Future<InvoiceResponse> createInvoice(CreateInvoiceParams params) async {
    requireOperationSupported('createInvoice');
    final env = await _channel.execute('createInvoice', {
      'terminalUUID': terminalUUID,
      ...params.toPayload(),
      'paramsJson': jsonEncode(params.toPayload()),
    });
    assertEnvelopeSuccess(env, 'createInvoice',
        fallbackMessage: 'Failed to create invoice');
    return adaptCreateInvoiceResult('createInvoice', env.data);
  }

  Future<InvoiceListResponse> getInvoiceList({int? page, int? limit}) async {
    requireOperationSupported('getInvoiceList');
    final env = await _channel.execute('getInvoiceList', {
      'terminalUUID': terminalUUID,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    assertEnvelopeSuccess(env, 'getInvoiceList',
        fallbackMessage: 'Failed to get invoice list');
    return adaptInvoiceListResult('getInvoiceList', env.data);
  }

  Future<InvoiceDetails> getInvoice(String invoiceId) async {
    requireOperationSupported('getInvoice');
    final env = await _channel.execute('getInvoice', {
      'terminalUUID': terminalUUID,
      'invoiceId': invoiceId,
    });
    assertEnvelopeSuccess(env, 'getInvoice',
        fallbackMessage: 'Failed to get invoice');
    return adaptInvoiceDetailsResult('getInvoice', env.data);
  }

  Future<void> shareReceipt(ShareReceiptParams params) async {
    requireOperationSupported('shareReceipt');
    final env = await _channel.execute('shareReceipt', {
      'terminalUUID': terminalUUID,
      ...params.toPayload(),
      'paramsJson': jsonEncode(params.toPayload()),
    });
    assertEnvelopeSuccess(env, 'shareReceipt',
        fallbackMessage: 'Failed to share receipt');
  }

  Future<void> shareInvoice(ShareInvoiceParams params) async {
    requireOperationSupported('shareInvoice');
    final env = await _channel.execute('shareInvoice', {
      'terminalUUID': terminalUUID,
      'paramsJson': jsonEncode(params.toMap()),
    });
    assertEnvelopeSuccess(env, 'shareInvoice',
        fallbackMessage: 'Failed to share invoice');
  }

  Future<CashierProductResponse> createProduct(
      CreateProductParams params) async {
    requireOperationSupported('createProduct');
    final env = await _channel.execute('createProduct', {
      'terminalUUID': terminalUUID,
      ...params.toPayload(),
      'paramsJson': jsonEncode(params.toPayload()),
    });
    assertEnvelopeSuccess(env, 'createProduct',
        fallbackMessage: 'Failed to create product');
    return adaptCreateProductResult('createProduct', env.data);
  }

  Future<CashierProductsListResponse> getAllProducts(
      {int? page, int? limit}) async {
    requireOperationSupported('getAllProducts');
    final env = await _channel.execute('getAllProducts', {
      'terminalUUID': terminalUUID,
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    assertEnvelopeSuccess(env, 'getAllProducts',
        fallbackMessage: 'Failed to get products');
    return adaptGetAllProductsResult('getAllProducts', env.data);
  }

  Future<CashierProductResponse> getProduct(String productId) async {
    requireOperationSupported('getProduct');
    final env = await _channel.execute('getProduct', {
      'terminalUUID': terminalUUID,
      'productId': productId,
    });
    assertEnvelopeSuccess(env, 'getProduct',
        fallbackMessage: 'Failed to get product');
    return adaptGetProductResult('getProduct', env.data);
  }

  Future<void> deleteProduct(String productId) async {
    requireOperationSupported('deleteProduct');
    final env = await _channel.execute('deleteProduct', {
      'terminalUUID': terminalUUID,
      'productId': productId,
    });
    assertEnvelopeSuccess(env, 'deleteProduct',
        fallbackMessage: 'Failed to delete product');
  }

  Future<bool> supportsReceiptViaNfc({bool requireEnabled = true}) async {
    requireOperationSupported('supportsReceiptViaNfc');
    final env = await _channel.execute('supportsReceiptViaNfc', {
      'terminalUUID': terminalUUID,
      'requireEnabled': requireEnabled,
    });
    assertEnvelopeSuccess(env, 'supportsReceiptViaNfc',
        fallbackMessage: 'Failed to check NFC receipt share support');
    return adaptSupportsReceiptViaNfcResult('supportsReceiptViaNfc', env.data);
  }

  Future<void> stopReceiptViaNfcShare() async {
    requireOperationSupported('stopReceiptViaNfcShare');
    final env = await _channel.execute('stopReceiptViaNfcShare', {
      'terminalUUID': terminalUUID,
    });
    assertEnvelopeSuccess(env, 'stopReceiptViaNfcShare',
        fallbackMessage: 'Failed to stop NFC receipt share');
  }

  Future<NfcShareStartResult> shareReceiptViaNfc(
      NfcShareStartParams params) async {
    requireOperationSupported('shareReceiptViaNfc');
    final prepared = _prepareNfcShareOperation(params, 'shareReceiptViaNfc');
    final env = await _channel.execute('shareReceiptViaNfc', prepared.payload);
    assertEnvelopeSuccess(env, 'shareReceiptViaNfc',
        fallbackMessage: 'Failed to start NFC receipt share');
    return adaptNfcShareStartResult('shareReceiptViaNfc', env.data);
  }

  Future<NfcShareStartResult> startShareUrlService(
      NfcShareStartParams params) async {
    requireOperationSupported('startShareUrlService');
    final prepared = _prepareNfcShareOperation(params, 'startShareUrlService');
    final env =
        await _channel.execute('startShareUrlService', prepared.payload);
    assertEnvelopeSuccess(env, 'startShareUrlService',
        fallbackMessage: 'Failed to start share URL service');
    return adaptNfcShareStartResult('startShareUrlService', env.data);
  }

  String _createNfcShareSessionId() {
    return 'nfc-${DateTime.now().millisecondsSinceEpoch}-'
        '${DateTime.now().microsecondsSinceEpoch % 100000}';
  }

  ({Map<String, dynamic> payload, String sessionId}) _prepareNfcShareOperation(
    NfcShareStartParams params,
    String operation,
  ) {
    final url = params.url.trim();
    if (url.isEmpty) {
      throw NearpayException('$operation requires url');
    }

    final sessionId = (params.sessionId ?? _createNfcShareSessionId()).trim();
    if (params.callbacks != null) {
      _activeNfcShareCallbacks[_txnKey(sessionId)] = params.callbacks!;
    }

    final payload = <String, dynamic>{
      'terminalUUID': terminalUUID,
      'url': url,
      'sessionId': sessionId,
    };
    if (params.timeoutMillis != null) {
      payload['timeoutMillis'] = params.timeoutMillis;
    }
    return (payload: payload, sessionId: sessionId);
  }
}
