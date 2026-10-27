// lib/flutter_terminal_sdk.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'domain/ports/nearpay_native_port.dart';
import 'domain/operations/bridge_operations.dart';
import 'errors/errors.dart';
import 'internal/composition.dart';
import 'domain/models/PermissionStatus.dart';
import 'domain/models/data/TerminalList.dart';
import 'domain/models/data/authenticator_response.dart';
import 'domain/models/data/ui_dock_position.dart';
import 'domain/models/nearpay_user_response.dart';
import 'domain/models/send_otp_response.dart';
import 'domain/models/linking_callbacks.dart';
import 'domain/models/terminal_response.dart';
import 'domain/models/terminal_sdk_initialization_listener.dart';
import 'domain/models/data/lifecycle_events.dart';
import 'domain/models/data/transaction_ui_message.dart';
import 'data/native/listener_set.dart';

export 'domain/models/linking_callbacks.dart';
export 'domain/models/nfc_share_callbacks.dart';
export 'domain/models/qr_void_callbacks.dart';
export 'domain/models/qr_refund_callbacks.dart';
export 'domain/models/data/lifecycle_events.dart';
export 'domain/models/data/terminal_operation.dart';
export 'domain/models/data/transaction_ui_message.dart';
export 'errors/errors.dart';
export 'errors/nearpay_native_error.dart';

enum Environment { sandbox, production, internal }

enum Country { sa, tr, usa, uae }

enum SupportSecondDisplay { enable, disable, initial }

enum NetworkConfiguration {
  networkDefault,
  simPreferred,
  simOnly,
}

class FlutterTerminalSdk {
  static final FlutterTerminalSdk _instance = FlutterTerminalSdk._internal();
  late TerminalSDKInitializationListener initializationListener;
  bool _legacyInitListenerSet = false;

  final ListenerSet<InitializationEventPayload> _initListeners =
      ListenerSet<InitializationEventPayload>();
  final ListenerSet<LogoutEventPayload> _logoutListeners =
      ListenerSet<LogoutEventPayload>();
  final ListenerSet<TerminalDisconnectEventPayload>
      _terminalDisconnectListeners =
      ListenerSet<TerminalDisconnectEventPayload>();
  final ListenerSet<TransactionUiMessage?> _uiMessageListeners =
      ListenerSet<TransactionUiMessage?>();

  late final BridgeComposition _composition;

  NearpayNativePort get _port => _composition.port;

  BridgeOperations get _ops => _composition.operations;

  final Map<String, LinkingCallbacks> _connectTerminalLinkingCallbacks = {};
  final Map<String, LinkingCallbacks> _getTerminalLinkingCallbacks = {};

  factory FlutterTerminalSdk() {
    return _instance;
  }

  FlutterTerminalSdk._internal() {
    _composition = createBridgeComposition(isInitialized: () => _initialized);
    _port.addMethodCallListener(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (kDebugMode) {
      debugPrint(
          "Flutter::: _handleMethodCall called with method: ${call.method}");
    }
    switch (call.method) {
      case 'terminalLinkingEvent':
        _handleTerminalLinkingEvent(call);
        break;
      case 'onSdkInitializationFailed':
        final args = Map<String, dynamic>.from(call.arguments);
        final error = args['error'] as String?;
        _initialized = false;
        _initListeners.emit(
          InitializationEventPayload(status: 'failure', message: error),
        );
        if (_legacyInitListenerSet) {
          initializationListener.onInitializationFailure
              ?.call(error ?? "Unknown error");
        }
        break;
      case 'onSdkInitialized':
        _initialized = true;
        _initListeners.emit(
          const InitializationEventPayload(status: 'success'),
        );
        if (_legacyInitListenerSet) {
          initializationListener.onInitializationSuccess?.call();
        }
        break;
      case 'NearpayTerminalOnLogout':
        _handleLogoutEvent(call);
        break;
      case 'NearpayTerminalOnDisconnect':
        _handleTerminalDisconnectEvent(call);
        break;
      case 'sdkUiMessage':
        _handleUiMessageEvent(call);
        break;
    }
  }

  void _handleLogoutEvent(MethodCall call) {
    final args = _argsAsMap(call.arguments);
    final userUUID =
        (args['userUUID'] ?? args['userId'] ?? args['uuid'] ?? args['id'] ?? '')
            .toString()
            .trim();
    if (userUUID.isEmpty) {
      return;
    }
    _logoutListeners.emit(LogoutEventPayload(userUUID: userUUID));
  }

  void _handleTerminalDisconnectEvent(MethodCall call) {
    final args = _argsAsMap(call.arguments);
    final terminalUUID = (args['terminalUUID'] ??
            args['terminalUuid'] ??
            args['terminalId'] ??
            args['uuid'] ??
            args['id'] ??
            '')
        .toString()
        .trim();
    if (terminalUUID.isEmpty) {
      return;
    }
    _terminalDisconnectListeners
        .emit(TerminalDisconnectEventPayload(terminalUUID: terminalUUID));
  }

  void _handleUiMessageEvent(MethodCall call) {
    final raw = call.arguments;
    if (raw == null) {
      _uiMessageListeners.emit(null);
      return;
    }
    if (raw is! Map) {
      return;
    }
    final args = _argsAsMap(raw);
    final holdTimeRaw = args['holdTime'];
    final holdTime = holdTimeRaw is num
        ? holdTimeRaw.toInt()
        : int.tryParse('${holdTimeRaw ?? ''}') ?? 0;
    _uiMessageListeners.emit(
      TransactionUiMessage(
        messageAr: (args['messageAr'] ?? '').toString(),
        messageEn: (args['messageEn'] ?? '').toString(),
        holdTime: holdTime,
      ),
    );
  }

  Map<String, dynamic> _argsAsMap(dynamic arguments) {
    if (arguments is Map) {
      return Map<String, dynamic>.from(arguments);
    }
    return <String, dynamic>{};
  }

  String _linkingKey(String terminalUUID) => terminalUUID.trim().toLowerCase();

  void _registerTerminalLinkingCallbacks(
    String operation,
    String terminalUUID,
    LinkingCallbacks? callbacks,
  ) {
    if (callbacks == null) return;
    final key = _linkingKey(terminalUUID);
    if (operation == 'connectTerminal') {
      _connectTerminalLinkingCallbacks[key] = callbacks;
    } else if (operation == 'getTerminal') {
      _getTerminalLinkingCallbacks[key] = callbacks;
    }
  }

  void _clearTerminalLinkingCallbacks(String operation, String key) {
    if (operation == 'connectTerminal') {
      _connectTerminalLinkingCallbacks.remove(key);
    } else if (operation == 'getTerminal') {
      _getTerminalLinkingCallbacks.remove(key);
    }
  }

  void _handleTerminalLinkingEvent(MethodCall call) {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    final operation =
        (args['operation'] ?? args['method'] ?? '').toString().trim();
    if (operation != 'connectTerminal' && operation != 'getTerminal') {
      return;
    }

    final terminalId = resolveTerminalLinkingEventId(args);
    if (terminalId.isEmpty) {
      return;
    }

    final callbacks = operation == 'connectTerminal'
        ? _connectTerminalLinkingCallbacks[terminalId]
        : _getTerminalLinkingCallbacks[terminalId];

    Map<String, dynamic>? data;
    final rawData = args['data'];
    if (rawData is Map) {
      data = Map<String, dynamic>.from(rawData);
    }

    final eventType = args['type']?.toString() ?? '';
    final handled = dispatchLinkingCallbacks(
      callbacks,
      type: eventType,
      message: args['message'] as String?,
      data: data,
    );

    if (handled &&
        (eventType == 'linkingCompleted' || eventType == 'linkingFailure')) {
      _clearTerminalLinkingCallbacks(operation, terminalId);
    }
  }

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize({
    required Environment environment,
    required Country country,
    required int? googleCloudProjectNumber,
    String? huaweiSafetyDetectApiKey,
    UiDockPosition? uiDockPosition,
    UiDockPosition? secondDisplayDockPosition,
    UiDockPosition? pinPosition,
    SupportSecondDisplay? supportSecondDisplay,
    NetworkConfiguration? networkConfiguration,
    int? networkConfigurationId,
    bool? requireNfc,
    TerminalSDKInitializationListener? initializationListener,
  }) async {
    if (initializationListener != null) {
      setInitializationListener(initializationListener);
    }
    final environmentString = environment.name;
    final countryString = country.name;
    final uiDockPositionString = uiDockPosition?.name;
    final secondDisplayDockPositionString = secondDisplayDockPosition?.name;
    final pinPositionString = pinPosition?.name;
    final supportSecondDisplayString = supportSecondDisplay?.name;
    final networkConfigurationString = networkConfiguration?.name;

    try {
      await _ops.initializeRaw({
        'environment': environmentString,
        'country': countryString,
        'googleCloudProjectNumber': googleCloudProjectNumber,
        'huaweiSafetyDetectApiKey': huaweiSafetyDetectApiKey,
        'uiDockPosition': uiDockPositionString,
        'secondDisplayDockPosition': secondDisplayDockPositionString,
        'supportSecondDisplay': supportSecondDisplayString,
        'pinPosition': pinPositionString,
        'requireNfc': requireNfc,
        if (networkConfigurationString != null)
          'networkConfiguration': networkConfigurationString,
        if (networkConfigurationId != null)
          'networkConfigurationId': networkConfigurationId,
        if (requireNfc != null) 'requireNfc': requireNfc,
      });
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Flutter::: Error initializing Nearpay Terminal SDK: $e");
      }
      _initialized = false;
      throw NearpayException("Failed to initialize Nearpay Terminal SDK: $e");
    }
  }

  void setInitializationListener(TerminalSDKInitializationListener listener) {
    initializationListener = listener;
    _legacyInitListenerSet = true;
  }

  NativeUnsubscribe addInitializationListener(
    void Function(InitializationEventPayload payload) callback,
  ) =>
      _initListeners.add(callback);

  NativeUnsubscribe addLogoutListener(
    void Function(LogoutEventPayload payload) callback,
  ) =>
      _logoutListeners.add(callback);

  NativeUnsubscribe addTerminalDisconnectListener(
    void Function(TerminalDisconnectEventPayload payload) callback,
  ) =>
      _terminalDisconnectListeners.add(callback);

  NativeUnsubscribe addUiMessageListener(
    void Function(TransactionUiMessage? payload) callback,
  ) {
    if (!_port.isAndroid) {
      throw NearpayException(
          'addUiMessageListener is only available on Android');
    }
    return _uiMessageListeners.add(callback);
  }

  Future<List<PermissionStatus>> checkRequiredPermissions() =>
      _ops.checkRequiredPermissions();

  Future<void> requestPermissions() async {
    if (!_port.isAndroid) {
      return;
    }
    await _ops.requestPermissions();
  }

  Future<bool> isNfcEnabled() {
    try {
      return _ops.isNfcEnabled();
    } catch (e) {
      throw NearpayException("Failed to get NFC status: $e");
    }
  }

  Future<bool> isWifiEnabled() {
    try{
      return _ops.isWifiEnabled();
    } catch (e) {
      throw NearpayException("Failed to get WiFi status: $e");
    }
  }

  Future<void> verifyNfcAndWifi() async {
    if (!_port.isAndroid) {
      return;
    }
    try {
      if (!await isNfcEnabled()) {
        throw NearpayException('NFC is disabled. Please enable NFC.');
      }
      if (!await isWifiEnabled()) {
        throw NearpayException('WiFi is disabled. Please enable WiFi.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthenticatorResponse> authenticator({
    String? type,
    String? value,
    String? mobileNumber,
    String? email,
  }) =>
      _ops.authenticator(
        type: type,
        value: value,
        mobileNumber: mobileNumber,
        email: email,
      );

  Future<OtpResponse> sendMobileOtp(String mobileNumber) =>
      _ops.sendMobileOtp(mobileNumber);

  Future<OtpResponse> sendEmailOtp(String email) => _ops.sendEmailOtp(email);

  Future<NearpayUser> verifyMobileOtp({
    required String mobileNumber,
    required String code,
  }) =>
      _ops.verifyMobileOtp(mobileNumber: mobileNumber, code: code);

  Future<NearpayUser> verifyEmailOtp({
    required String email,
    required String code,
  }) =>
      _ops.verifyEmailOtp(email: email, code: code);

  Future<TerminalModel> jwtLogin({
    required String jwt,
  }) =>
      _ops.jwtLogin(jwt: jwt);

  Future<NearpayUser> getUserByUUID({
    required String uuid,
  }) =>
      _ops.getUserByUUID(uuid: uuid);

  Future<NearpayUser> getUser({String? userUUID}) {
    final resolved = (userUUID ?? '').trim();
    if (resolved.isEmpty) {
      throw NearpayException('userUUID is required.');
    }
    return getUserByUUID(uuid: resolved);
  }

  Future<NearpayUser> getUserByUuid({String? userUUID}) =>
      getUser(userUUID: userUUID);

  Future<List<NearpayUser>> getUsers() => _ops.getUsers();

  Future<String> logout({
    required String userUUID,
  }) =>
      _ops.logout(userUUID: userUUID);

  Future<TerminalModel> getTerminal({
    required String terminalUUID,
    LinkingCallbacks? linkingCallbacks,
  }) async {
    final resolvedTerminalUUID = terminalUUID.trim();
    final linkingKey = _linkingKey(resolvedTerminalUUID);
    _registerTerminalLinkingCallbacks(
      'getTerminal',
      resolvedTerminalUUID,
      linkingCallbacks,
    );
    final keepOnIos = _port.isIOS && linkingCallbacks != null;

    try {
      return await _ops.getTerminal(terminalUUID: resolvedTerminalUUID);
    } catch (error) {
      _clearTerminalLinkingCallbacks('getTerminal', linkingKey);
      rethrow;
    } finally {
      if (linkingCallbacks != null && !keepOnIos) {
        _clearTerminalLinkingCallbacks('getTerminal', linkingKey);
      }
    }
  }

  Future<TerminalList> getTerminalList(String uuid,
          {int? page, int? pageSize, String? nameFilter}) =>
      _ops.getTerminalList(uuid,
          page: page, pageSize: pageSize, nameFilter: nameFilter);

  Future<TerminalModel> connectTerminal({
    required String tid,
    required String userUUID,
    required String terminalUUID,
    String? name,
    LinkingCallbacks? linkingCallbacks,
  }) async {
    final resolvedTerminalUUID = terminalUUID.trim();
    final linkingKey = _linkingKey(resolvedTerminalUUID);
    _registerTerminalLinkingCallbacks(
      'connectTerminal',
      resolvedTerminalUUID,
      linkingCallbacks,
    );
    final keepOnIos = _port.isIOS && linkingCallbacks != null;

    try {
      return await _ops.connectTerminal(
        tid: tid,
        userUUID: userUUID,
        terminalUUID: resolvedTerminalUUID,
        name: name,
      );
    } catch (error) {
      _clearTerminalLinkingCallbacks('connectTerminal', linkingKey);
      rethrow;
    } finally {
      if (linkingCallbacks != null && !keepOnIos) {
        _clearTerminalLinkingCallbacks('connectTerminal', linkingKey);
      }
    }
  }

  Future<bool> disconnectTerminal() => _ops.disconnectTerminal();

  Future<String> getVersion() => _ops.getVersion();

  @Deprecated('Use getVersion()')
  Future<String> getPlatformVersion() {
    return getVersion();
  }
}
