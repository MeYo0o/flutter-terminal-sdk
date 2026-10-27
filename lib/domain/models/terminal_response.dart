import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_terminal_sdk/domain/models/card_reader_event_normalizer.dart';
import 'package:flutter_terminal_sdk/domain/models/data/intent_details.dart';
import 'package:flutter_terminal_sdk/domain/models/data/generated_qr_code.dart';
import 'package:flutter_terminal_sdk/domain/models/data/qr_status_response.dart';
import 'package:flutter_terminal_sdk/domain/models/data/reconciliation_list_response.dart';
import 'package:flutter_terminal_sdk/domain/models/linking_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/nfc_share_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/purchase_void_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/authorized_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/purchase_with_qr_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/qr_void_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/qr_refund_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/refund_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/refund_void_callbacks.dart';
import 'package:flutter_terminal_sdk/domain/models/routing_callbacks.dart';
import '../../data/adapters/native/index.dart';
import '../../data/capabilities/operation_capabilities.dart';
import '../../data/mappers/native/operation_mapper.dart';
import '../../errors/errors.dart';
import '../../helper/platform_support.dart';
import '../../data/sources/native/method_channel_native_source.dart';
import '../ports/nearpay_native_port.dart';
import '../../data/native/operation_status.dart';
import 'capture_authorization_with_tap_callbacks.dart';
import 'card_reader_callbacks.dart';
import 'data/capture_response.dart';
import 'data/cashier/cashier_requests.dart';
import 'data/cashier/invoice.dart';
import 'data/cashier/product.dart';
import 'data/dto/payment_text.dart';
import 'data/dto/proxy_room_response.dart';
import 'data/dto/routing_profile.dart';
import 'data/authorize_response.dart';
import 'data/intent_response_turkey.dart';
import 'data/purchase_response.dart';
import 'data/reconcile_response.dart';
import 'data/refund_response.dart';
import 'data/reconciliation_receipts_response.dart';
import 'data/receipts_response.dart' show ReceiptDto;
import 'data/increment_response.dart';
import 'data/reverse_response.dart';
import 'data/terminal_config.dart';
import 'data/terminal_operation.dart';
import 'data/void_authorization_response.dart';
import 'intents_list_response.dart';
import 'nearpay_user_response.dart';
import 'open_refund_callbacks.dart';
import 'purchase_callbacks.dart';
import 'void_authorization_with_tap_callbacks.dart';
import 'data/payment_scheme.dart';
import 'data/dto/installment_option.dart';
import 'util/id_params.dart';
import 'util/json_pick.dart';
import 'util/perform_callbacks.dart';
import 'util/refund_channel_payload.dart';

part 'terminal_response_events.dart';
part 'terminal_response_event_routing.dart';
part 'terminal_response_cashier.dart';
part 'terminal_response_queries.dart';
part 'terminal_response_reconciliation.dart';
part 'terminal_response_authorization.dart';
part 'terminal_response_payments.dart';
part 'terminal_response_routing.dart';
part 'terminal_response_qr.dart';
part 'terminal_response_refund.dart';

class TerminalModel {
  final String? name;
  final PaymentText? paymentText;
  final String? terminalUUID;
  final String? tid;
  final String? client;

  final NearpayNativePort _channel = MethodChannelNativeSource.instance;
  final Map<String, AuthorizedCallbacks> _activeAuthorizeCallbacks = {};
  final Map<String, PurchaseWithQrCallbacks> _activePurchaseWithQRCallbacks =
      {};
  final Map<String, PurchaseCallbacks> _activePurchaseCallbacks = {};
  final Map<String, RoutingLookupCallbacks> _activeRoutingLookupCallbacks = {};
  final Map<String, PurchaseCallbacks> _activePurchaseWithTipCallbacks = {};
  final Map<String, PurchaseCallbacks> _activeInstallmentsCallbacks = {};
  final Map<String, PurchaseVoidCallbacks> _activePurchaseVoidCallbacks = {};
  final Map<String, RefundCallbacks> _activeRefundCallbacks = {};
  final Map<String, OpenRefundCallbacks> _activeOpenRefundCallbacks = {};
  final Map<String, RefundVoidCallbacks> _activeRefundVoidCallbacks = {};
  final Map<String, CaptureAuthorizationWithTapCallbacks>
      _activeCaptureAuthorizationWithTapCallbacks = {};
  final Map<String, VoidAuthorizationWithTapCallbacks>
      _activeVoidAuthorizationWithTapCallbacks = {};
  final Map<String, QrVoidCallbacks> _activeQrVoidCallbacks = {};
  final Set<String> _qrVoidUiPresented = {};
  final Map<String, QrRefundCallbacks> _activeQrRefundCallbacks = {};
  final Set<String> _qrRefundUiPresented = {};
  final Map<String, NfcShareCallbacks> _activeNfcShareCallbacks = {};

  TerminalModel({
    this.name,
    this.paymentText,
    required this.terminalUUID,
    required this.tid,
    this.client,
  }) {
    _disposeMethodCallListener =
        _channel.addMethodCallListener(_handleMethodCall);
  }

  late final NativeUnsubscribe _disposeMethodCallListener;

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      tid: json['tid'] as String?,
      terminalUUID: json['terminalUUID'] as String?,
      name: json['name'] as String?,
      client: json['client'] as String?,
      paymentText: json['paymentText'] != null
          ? PaymentText.fromJson(json['paymentText'])
          : null,
    );
  }

  @override
  String toString() {
    return 'TerminalModel(name: $name, paymentText: $paymentText, terminalUUID: $terminalUUID, tid: $tid , client: $client)';
  }

  Future<bool> isTerminalReady() async {
    final env = await _channel.execute(
      'isTerminalReady',
      {'terminalUUID': terminalUUID},
    );
    assertEnvelopeSuccess(env, 'isTerminalReady',
        fallbackMessage: 'Failed to check terminal readiness');
    final data = env.data;
    if (data is Map) {
      return toBoolSafe(pickKey(data, ['isReady', 'is_ready']));
    }
    return toBoolSafe(data);
  }

  Future<void> dismissReaderUi() async {
    final env = await _channel.execute(
      'dismissReaderUi',
      {'terminalUUID': terminalUUID},
    );
    assertEnvelopeSuccess(env, 'dismissReaderUi',
        fallbackMessage: 'Failed to dismiss reader UI');
  }

  Future<void> cancelReading() async {
    final env = await _channel.execute(
      'cancelReading',
      {'terminalUUID': terminalUUID},
    );
    assertEnvelopeSuccess(env, 'cancelReading',
        fallbackMessage: 'Failed to cancel reading');
  }

  Future<String> printMadaReceipt({
    required ReceiptDto receipt,
    int? fontSize,
    int? receiptWidth,
  }) async {
    requireOperationSupported('printMadaReceipt');
    final raw = receipt.data;
    final String payload =
        raw is String ? raw : jsonEncode(raw ?? <String, dynamic>{});
    final env = await _channel.execute(
      'printMadaReceipt',
      {
        'terminalUUID': terminalUUID,
        'receiptData': payload,
        'fontSize': fontSize,
        'receiptWidth': receiptWidth,
      },
    );
    assertEnvelopeSuccess(env, 'printMadaReceipt',
        fallbackMessage: 'Failed to print MADA receipt');
    final data = env.data;
    if (data is Map && data['image'] != null) {
      return data['image'].toString();
    }
    throw NearpayException('Invalid printMadaReceipt response');
  }

  Future<void> cancelTransaction({
    String? id,
    String? transactionUUID,
    String? transactionUuid,
  }) async {
    final cancelId = resolveCancelId({
      if (id != null) 'id': id,
      if (transactionUUID != null) 'transactionUUID': transactionUUID,
      if (transactionUuid != null) 'transactionUuid': transactionUuid,
    });
    final env = await _channel.execute(
      'cancelTransaction',
      {
        'terminalUUID': terminalUUID,
        'id': cancelId,
        'transactionUUID': cancelId,
        'transactionUuid': cancelId,
      },
    );
    assertEnvelopeSuccess(env, 'cancelTransaction',
        fallbackMessage: 'Failed to cancel transaction');
  }

  String _txnKey(String id) => normalizeTxnId(id);

  String _refundCallbackKey({
    required String newRefundIntentUUID,
    required String originalIntentUUID,
  }) =>
      isAndroidPlatform
          ? _txnKey(originalIntentUUID)
          : _txnKey(newRefundIntentUUID);

  void dispose() {
    _disposeMethodCallListener();
    _activePurchaseWithQRCallbacks.clear();
    _activePurchaseCallbacks.clear();
    _activeRoutingLookupCallbacks.clear();
    _activeRefundCallbacks.clear();
    _activeOpenRefundCallbacks.clear();
    _activePurchaseVoidCallbacks.clear();
    _activeRefundVoidCallbacks.clear();
    _activeAuthorizeCallbacks.clear();
    _activeCaptureAuthorizationWithTapCallbacks.clear();
    _activeVoidAuthorizationWithTapCallbacks.clear();
    _activeQrVoidCallbacks.clear();
    _qrVoidUiPresented.clear();
    _activeQrRefundCallbacks.clear();
    _qrRefundUiPresented.clear();
    _activePurchaseWithTipCallbacks.clear();
    _activeInstallmentsCallbacks.clear();
    _activeNfcShareCallbacks.clear();
  }
}
