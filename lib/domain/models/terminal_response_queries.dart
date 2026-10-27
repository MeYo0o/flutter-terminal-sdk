part of 'terminal_response.dart';

extension TerminalModelQueryOps on TerminalModel {
  Future<IntentDetails> getIntentDetails({
    required String intentUUID,
    String? intentUuid,
  }) async {
    final resolvedUuid = intentUUID.trim().isNotEmpty
        ? intentUUID.trim()
        : (intentUuid?.trim() ?? '');
    if (resolvedUuid.isEmpty) {
      throw NearpayException(
          'getIntentDetails requires intentUUID or intentUuid');
    }
    final env = await _channel.execute(
      'getIntentDetails',
      {
        "terminalUUID": terminalUUID,
        "intentUUID": resolvedUuid,
        "intentUuid": resolvedUuid,
      },
    );
    assertEnvelopeSuccess(env, 'getIntentDetails',
        fallbackMessage: "Get Transaction Details Failed");
    return adaptIntentDetailsResult('getIntentDetails', env.data);
  }

  @Deprecated('Use getIntentDetails instead')
  Future<IntentDetails> getIntent({
    required String intentUUID,
  }) =>
      getIntentDetails(intentUUID: intentUUID);

  Future<IntentDetails> getTransactionDetails({
    required String transactionUUID,
  }) =>
      getIntentDetails(intentUUID: transactionUUID);

  Future<NearpayUser> getUser(String uuid) async {
    final env = await _channel.execute('getUser', {
      'terminalUUID': terminalUUID,
      'uuid': uuid,
    });
    assertEnvelopeSuccess(env, 'getUser',
        fallbackMessage: 'Failed to get user');
    return adaptUserResult('getUser', env.data);
  }

  Future<bool> batchCapture() async {
    final env = await _channel.execute(
      'batchCapture',
      {'terminalUUID': terminalUUID},
    );
    assertEnvelopeSuccess(env, 'batchCapture',
        fallbackMessage: 'Batch capture failed');
    final data = env.data;
    if (data is Map) {
      return toBoolSafe(pickKey(data, ['value']));
    }
    return toBoolSafe(data);
  }

  Future<bool> isOperationSupported(String operation) async {
    final normalized = canonicalTerminalOperationName(operation);
    if (normalized.isEmpty) {
      throw NearpayException('isOperationSupported requires an operation');
    }
    final env = await _channel.execute(
      'isOperationSupported',
      {
        'terminalUUID': terminalUUID,
        'operation': normalized,
      },
    );
    assertEnvelopeSuccess(env, 'isOperationSupported',
        fallbackMessage: 'Failed to resolve operation support');
    final data = env.data;
    if (data is Map) {
      return toBoolSafe(pickKey(data, ['supported']));
    }
    return toBoolSafe(data);
  }

  Future<RoutingProfile> getRoutingProfile() async {
    requireOperationSupported('getRoutingProfile');
    try {
      final env = await _channel.execute(
        'getRoutingProfile',
        {
          "terminalUUID": terminalUUID,
        },
      );
      assertEnvelopeSuccess(env, 'getRoutingProfile',
          fallbackMessage: "Get Transaction Details Failed");
      return adaptRoutingProfileResult('getRoutingProfile', env.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<IntentsListResponse> getIntentList({
    int? page,
    int? pageSize,
    String? status,
    bool? isReconciled,
    num? date,
    String? startDate,
    String? endDate,
    String? customerReferenceNumber,
  }) async {
    final env = await _channel.execute(
      'getIntentList',
      {
        "terminalUUID": terminalUUID,
        "page": page,
        "pageSize": pageSize,
        "status": status,
        "isReconciled": isReconciled,
        "date": date,
        "startDate": startDate,
        "endDate": endDate,
        "customerReferenceNumber": customerReferenceNumber,
      },
    );
    assertEnvelopeSuccess(env, 'getIntentList',
        fallbackMessage: 'Failed to retrieve Transactions: Unknown error');
    return adaptIntentsListResult('getIntentList', env.data);
  }

  @Deprecated('Use getIntentList instead')
  Future<IntentsListResponse> getTransactionList({
    int? page,
    int? pageSize,
    String? status,
    bool? isReconciled,
    num? date,
    String? startDate,
    String? endDate,
    String? customerReferenceNumber,
  }) =>
      getIntentList(
        page: page,
        pageSize: pageSize,
        status: status,
        isReconciled: isReconciled,
        date: date,
        startDate: startDate,
        endDate: endDate,
        customerReferenceNumber: customerReferenceNumber,
      );
}
