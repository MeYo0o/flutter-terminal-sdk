part of 'terminal_response.dart';

extension TerminalModelReconciliationOps on TerminalModel {
  Future<ReconciliationListResponse> getReconcileList({
    required int page,
    required int pageSize,
    num? startDate,
    num? endDate,
  }) async {
    final env = await _channel.execute(
      'getReconcileList',
      {
        "terminalUUID": terminalUUID,
        "page": page,
        "pageSize": pageSize,
        if (startDate != null) "startDate": startDate,
        if (endDate != null) "endDate": endDate,
      },
    );
    assertEnvelopeSuccess(env, 'getReconcileList',
        fallbackMessage: 'Failed to retrieve Reconcile: Unknown error');
    return adaptReconciliationListResult('getReconcileList', env.data);
  }

  Future<ReconciliationListResponse> getReconciliationList({
    required int page,
    required int pageSize,
    num? startDate,
    num? endDate,
  }) =>
      getReconcileList(
        page: page,
        pageSize: pageSize,
        startDate: startDate,
        endDate: endDate,
      );

  Future<ReconciliationReceiptsResponse> getReconcileDetails({
    required String uuid,
  }) async {
    final env = await _channel.execute(
      'getReconcileDetails',
      {
        "terminalUUID": terminalUUID,
        "uuid": uuid,
      },
    );
    assertEnvelopeSuccess(env, 'getReconcileDetails',
        fallbackMessage: "Get Reconcile Details Failed");
    return adaptReconciliationReceiptsResult('getReconcileDetails', env.data);
  }

  Future<ReconciliationResponse> getReconciliation({
    required String uuid,
  }) async {
    try {
      final env = await _channel.execute(
        'getReconciliation',
        {
          "terminalUUID": terminalUUID,
          "uuid": uuid,
        },
      );
      assertEnvelopeSuccess(env, 'getReconciliation',
          fallbackMessage: "Get Reconcile Details Failed");
      return adaptReconciliationResult('getReconciliation', env.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ReconciliationReceiptsResponse> reconcile() async {
    final env = await _channel.execute(
      'reconcile',
      {
        'terminalUUID': terminalUUID,
      },
    );
    assertEnvelopeSuccess(env, 'reconcile',
        fallbackMessage: 'Failed to connect to terminal');
    return adaptReconciliationReceiptsResult('reconcile', env.data);
  }
}
