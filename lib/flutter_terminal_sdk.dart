// lib/flutter_terminal_sdk.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'errors/errors.dart';
import 'models/PermissionStatus.dart';
import 'models/data/Pagination.dart';
import 'models/data/TerminalList.dart';
import 'models/data/ui_dock_position.dart';
import 'models/nearpay_user_response.dart';
import 'models/send_otp_response.dart';
import 'models/terminal_connection_response.dart';
import 'models/terminal_response.dart';
import 'models/terminal_sdk_initialization_listener.dart';

export 'models/data/terminal_config.dart';

/// Enumerations for environment/country
enum Environment { sandbox, production, internal }

enum Country { sa, tr, usa, jo , uae }

enum SupportSecondDisplay { enable, disable, initial }

/// Cellular vs Wi‑Fi preference for the native Android SDK `NetworkConfiguration`.
enum NetworkConfiguration {
  /// Same as NearPay `NetworkConfiguration.DEFAULT`.
  networkDefault,
  simPreferred,
  simOnly,
}

class FlutterTerminalSdk {
  static final FlutterTerminalSdk _instance = FlutterTerminalSdk._internal();
  late TerminalSDKInitializationListener initializationListener;

  factory FlutterTerminalSdk() {
    return _instance;
  }

  FlutterTerminalSdk._internal()
      : _channel = const MethodChannel('nearpay_plugin') {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    print("Flutter::: _handleMethodCall called with method: ${call.method}");
    switch (call.method) {
      case 'onSdkInitializationFailed':
        final args = Map<String, dynamic>.from(call.arguments);
        final error = args['error'] as String?;
        initializationListener
            .onInitializationFailure!(error ?? "Unknown error");
        break;
      case 'onSdkInitialized':
        initializationListener.onInitializationSuccess!();
        break;
    }
  }

  final MethodChannel _channel;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<Map<String, dynamic>> _callAndReturnMapResponse(String methodName,
      dynamic data,) async {
    if (!_initialized) {
      throw NearpayException("Cannot call $methodName before initialization");
    }
    final tempResponse = await _channel.invokeMethod(methodName, data);
    return jsonDecode(jsonEncode(tempResponse));
  }

  /// Initialize the SDK
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
    /// When set, overrides [networkConfiguration] (NearPay `NetworkConfiguration.fromId`).
    int? networkConfigurationId,
    TerminalSDKInitializationListener? initializationListener,
  }) async {
    if (initializationListener != null) {
      setInitializationListener(initializationListener);
    }
    final environmentString =
        environment.name; // "sandbox" or "production" or "internal"
    final countryString = country.name; // "sa", "tr", or "usa"
    final uiDockPositionString = uiDockPosition?.name; // "sa", "tr", or "usa"
    final secondDisplayDockPositionString =
        secondDisplayDockPosition?.name;
    final pinPositionString =
        pinPosition?.name;
    final supportSecondDisplayString =
        supportSecondDisplay?.name; // "enabled", "disabled", "auto"
    final networkConfigurationString = networkConfiguration?.name;

    try {
      final response = await _channel.invokeMethod('initialize', {
        'environment': environmentString,
        'country': countryString,
        'googleCloudProjectNumber': googleCloudProjectNumber,
        'huaweiSafetyDetectApiKey': huaweiSafetyDetectApiKey,
        'uiDockPosition': uiDockPositionString,
        'secondDisplayDockPosition': secondDisplayDockPositionString,
        'supportSecondDisplay': supportSecondDisplayString,
        'pinPosition': pinPositionString,
        if (networkConfigurationString != null)
          'networkConfiguration': networkConfigurationString,
        if (networkConfigurationId != null)
          'networkConfigurationId': networkConfigurationId,
      });
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print("Flutter::: Error initializing Nearpay Terminal SDK: $e");
      }
      _initialized = false;
      throw NearpayException("Failed to initialize Nearpay Terminal SDK: $e");
    }
  }

  void setInitializationListener(TerminalSDKInitializationListener listener) {
    initializationListener = listener;
  }

  //checkRequiredPermissions
  Future<List<PermissionStatus>> checkRequiredPermissions() async {
    try {
      final response = await _channel.invokeMethod('checkRequiredPermissions');
      if (response["status"] == "success") {
        final data = response["data"];
        if (kDebugMode) {
          print("data $data");
        }
        return response["data"]
            .map<PermissionStatus>(
                (permission) => PermissionStatus.fromJson(permission))
            .toList();
      } else {
        final errorMsg = response["message"] ?? "Failed to send mobile OTP";
        throw NearpayException(errorMsg);
      }
    } catch (e) {
      throw NearpayException("Failed to check required permissions: $e");
    }
  }

  //check nfc
  Future<bool> isNfcEnabled() async {
    try {
      final response = await _channel.invokeMethod('isNfcEnabled');
      return response["data"];
    } catch (e) {
      throw NearpayException("Failed to get NFC status: $e");
    }
  }

  //check wifi
  Future<bool> isWifiEnabled() async {
    try {
      final response = await _channel.invokeMethod('isWifiEnabled');
      return response["data"];
    } catch (e) {
      throw NearpayException("Failed to get Wifi status: $e");
    }
  }

  /// Send Mobile OTP
  Future<OtpResponse> sendMobileOtp(String mobileNumber) async {
    final response = await _callAndReturnMapResponse(
      'sendMobileOtp',
      {"mobileNumber": mobileNumber},
    );

    if (response["status"] == "success") {
      final data = response["data"];
      return OtpResponse.fromJson(Map<String, dynamic>.from(data));
    } else {
      final errorMsg = response["message"] ?? "Failed to send mobile OTP";
      throw NearpayException(errorMsg);
    }
  }

  /// Send Email OTP
  Future<OtpResponse> sendEmailOtp(String email) async {
    final response = await _callAndReturnMapResponse(
      'sendEmailOtp',
      {"email": email.trim()},
    );

    if (response["status"] == "success") {
      final data = response["data"];
      return OtpResponse.fromJson(Map<String, dynamic>.from(data));
    } else {
      final errorMsg = response["message"] ?? "Failed to send email OTP";
      throw NearpayException(errorMsg);
    }
  }

  /// Verify Mobile OTP
  Future<NearpayUser> verifyMobileOtp({
    required String mobileNumber,
    required String code,
  }) async {
    final response = await _callAndReturnMapResponse(
      'verifyMobileOtp',
      {
        'mobileNumber': mobileNumber,
        'code': code,
        // 'deviceToken': deviceToken,
      },
    );

    if (response["status"] == "success") {
      final data = response["data"];
      return NearpayUser.fromJson(Map<String, dynamic>.from(data));
    } else {
      final errorMsg = response["message"] ?? "Failed to verify mobile OTP";
      throw NearpayException(errorMsg);
    }
  }

  /// Verify Email OTP
  Future<NearpayUser> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final response = await _callAndReturnMapResponse(
      'verifyEmailOtp',
      {
        'email': email,
        'code': code,
      },
    );

    if (response["status"] == "success") {
      final data = response["data"];
      return NearpayUser.fromJson(Map<String, dynamic>.from(data));
    } else {
      final errorMsg = response["message"] ?? "Failed to verify email OTP";
      throw NearpayException(errorMsg);
    }
  }

  /// Verify Email OTP
  Future<TerminalModel> jwtLogin({
    required String jwt,
  }) async {
    final response = await _callAndReturnMapResponse(
      'jwtVerify',
      {
        'jwt': jwt,
      },
    );

    if (response["status"] == "success") {
      final data = response['data'];
      return TerminalModel.fromJson(Map<String, dynamic>.from(data));
    } else {
      final errorMsg = response["message"] ?? "Failed to verify email OTP";
      throw NearpayException(errorMsg);
    }
  }

  /// get User
  Future<NearpayUser> getUserByUUID({
    required String uuid,
  }) async {
    final response = await _callAndReturnMapResponse(
      'getUser',
      {
        'uuid': uuid,
      },
    );

    if (response["status"] == "success") {
      final data = response["data"];
      return NearpayUser.fromJson(Map<String, dynamic>.from(data));
    } else {
      final errorMsg = response["message"] ?? "Failed to get user";
      throw NearpayException(errorMsg);
    }
  }

  /// get Users
  Future<List<NearpayUser>> getUsers() async {
    final response = await _callAndReturnMapResponse('getUsers', {});

    // Checking the status of the response
    if (response["status"] == "success") {
      final data = response["data"];

      // Ensure that data is a Map<String, dynamic> where each key is a user ID
      if (data is Map) {
        List<NearpayUser> userList = [];

        // Iterate through the map to create a list of NearpayUser objects
        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            // Create a NearpayUser object from the map value (which should contain 'uuid' and 'name')
            userList
                .add(NearpayUser.fromJson(Map<String, dynamic>.from(value)));
          }
        });

        return userList;
      } else {
        throw NearpayException("Invalid data format");
      }
    } else {
      // Handle error if the response status is not "success"
      final errorMsg = response["message"] ?? "Failed to get users";
      throw NearpayException(errorMsg);
    }
  }

  /// logout
  Future<String> logout({
    required String userUUID,
  }) async {
    final response = await _callAndReturnMapResponse(
      'logout',
      {
        'userUUID': userUUID,
      },
    );

    if (response["status"] == "success") {
      return response["message"];
    } else {
      final errorMsg = response["message"] ?? "Failed to logout";
      throw NearpayException(errorMsg);
    }
  }

  /// get terminal
  Future<TerminalModel> getTerminal({
    required String terminalUUID,
  }) async {
    final response = await _callAndReturnMapResponse(
      'getTerminal',
      {
        'terminalUUID': terminalUUID,
      },
    );

    if (response["status"] == "success") {
      final data = response['data'] as Map<String, dynamic>;
      return TerminalModel.fromJson(data);
    } else {
      final errorMsg = response["message"] ?? "Failed to get user";
      throw NearpayException(errorMsg);
    }
  }

  /// getTerminalList
  Future<TerminalList> getTerminalList(String uuid,
      {int? page, int? pageSize}) async {
    final result = await _callAndReturnMapResponse(
      'getTerminalList',
      {
        'uuid': uuid,
        "page": page,
        "pageSize": pageSize,
      },
    );
    final status = result['status'];
    if (status == 'success') {
      final data = result['data'] as Map<String, dynamic>;

      return TerminalList.fromJson(data);
    } else {
      final message = result['message'] ?? 'Unknown error';
      throw NearpayException('Failed to retrieve terminals: $message');
    }
  }

  /// connectTerminal
  Future<TerminalModel> connectTerminal({
    required String tid,
    required String userUUID,
    required String terminalUUID,
  }) async {
    final response = await _callAndReturnMapResponse(
      'connectTerminal',
      {
        'tid': tid,
        'userUUID': userUUID,
        'terminalUUID': terminalUUID,
      },
    );

    final status = response['status'];
    if (status == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      return TerminalModel.fromJson(data);
    } else {
      final message = response['message'] ?? 'Failed to connect to terminal';
      throw NearpayException(message);
    }
  }

// getPlatformVersion() {
//   return _channel.invokeMethod<String>('getPlatformVersion');
// }

  getPlatformVersion() {
    return "42";
  }
}
