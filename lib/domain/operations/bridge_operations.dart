import '../../data/adapters/native/auth_adapter.dart';
import '../../data/adapters/native/cashier_adapter.dart';
import '../../data/adapters/native/terminal_adapter.dart';
import '../../data/capabilities/operation_capabilities.dart';
import '../../data/native/native_envelope.dart';
import '../ports/nearpay_native_port.dart';
import '../../data/native/operation_status.dart';
import '../../errors/errors.dart';
import '../models/PermissionStatus.dart';
import '../models/data/TerminalList.dart';
import '../models/data/authenticator_response.dart';
import '../models/nearpay_user_response.dart';
import '../models/send_otp_response.dart';
import '../models/terminal_response.dart';

class BridgeOperations {
  BridgeOperations({
    required NearpayNativePort port,
    required bool Function() isInitialized,
  })  : _port = port,
        _isInitialized = isInitialized;

  final NearpayNativePort _port;
  final bool Function() _isInitialized;

  bool get isIOS => _port.isIOS;

  Future<NativeEnvelope> _execute(String methodName, [dynamic data]) async {
    if (!_isInitialized()) {
      throw NearpayException("Cannot call $methodName before initialization");
    }
    return _port.execute(methodName, data);
  }

  Future<void> initializeRaw(Map<String, dynamic> payload) async {
    await _port.invokeRaw('initialize', payload);
  }

  Future<List<PermissionStatus>> checkRequiredPermissions() async {
    try {
      final env = await _port.execute('checkRequiredPermissions');
      assertEnvelopeSuccess(env, 'checkRequiredPermissions',
          fallbackMessage: 'Failed to check required permissions');
      return adaptPermissionStatusResult('checkRequiredPermissions', env.data);
    } catch (e) {
      throw NearpayException("Failed to check required permissions: $e");
    }
  }

  Future<bool> isNfcEnabled() async {
    try {
      final env = await _port.execute('isNfcEnabled');
      return env.data as bool;
    } catch (e) {
      throw NearpayException("Failed to get NFC status: $e");
    }
  }

  Future<bool> isWifiEnabled() async {
    try {
      final env = await _port.execute('isWifiEnabled');
      return env.data as bool;
    } catch (e) {
      throw NearpayException("Failed to get Wifi status: $e");
    }
  }

  Future<void> requestPermissions() async {
    final raw = await _port.invokeRaw('requestPermissions', <String, dynamic>{});
    final env = NativeEnvelope.from(raw);
    assertEnvelopeSuccess(env, 'requestPermissions',
        fallbackMessage: 'Failed to request permissions');
  }

  Future<AuthenticatorResponse> authenticator({
    String? type,
    String? value,
    String? mobileNumber,
    String? email,
  }) async {
    requireOperationSupported('authenticator');
    final env = await _execute('authenticator', {
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (mobileNumber != null) 'mobileNumber': mobileNumber,
      if (email != null) 'email': email,
    });
    assertEnvelopeSuccess(env, 'authenticator',
        fallbackMessage: "Failed to authenticate");
    return adaptAuthenticatorResult('authenticator', env.data);
  }

  Future<OtpResponse> sendMobileOtp(String mobileNumber) async {
    final env = await _execute('sendMobileOtp', {"mobileNumber": mobileNumber});
    assertEnvelopeSuccess(env, 'sendMobileOtp',
        fallbackMessage: "Failed to send mobile OTP");
    return adaptOtpResult('sendMobileOtp', env.data);
  }

  Future<OtpResponse> sendEmailOtp(String email) async {
    final env = await _execute('sendEmailOtp', {"email": email.trim()});
    assertEnvelopeSuccess(env, 'sendEmailOtp',
        fallbackMessage: "Failed to send email OTP");
    return adaptOtpResult('sendEmailOtp', env.data);
  }

  Future<NearpayUser> verifyMobileOtp({
    required String mobileNumber,
    required String code,
  }) async {
    final env = await _execute('verifyMobileOtp', {
      'mobileNumber': mobileNumber,
      'code': code,
    });
    assertEnvelopeSuccess(env, 'verifyMobileOtp',
        fallbackMessage: "Failed to verify mobile OTP");
    return adaptUserResult('verifyMobileOtp', env.data);
  }

  Future<NearpayUser> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final env = await _execute('verifyEmailOtp', {
      'email': email,
      'code': code,
    });
    assertEnvelopeSuccess(env, 'verifyEmailOtp',
        fallbackMessage: "Failed to verify email OTP");
    return adaptUserResult('verifyEmailOtp', env.data);
  }

  Future<TerminalModel> jwtLogin({required String jwt}) async {
    final env = await _execute('jwtVerify', {'jwt': jwt});
    assertEnvelopeSuccess(env, 'jwtVerify',
        fallbackMessage: "Failed to login with JWT");
    return adaptTerminalModelResult('jwtVerify', env.data);
  }

  Future<NearpayUser> getUserByUUID({required String uuid}) async {
    final env = await _execute('getUser', {'uuid': uuid});
    assertEnvelopeSuccess(env, 'getUser',
        fallbackMessage: "Failed to get user");
    return adaptUserResult('getUser', env.data);
  }

  Future<List<NearpayUser>> getUsers() async {
    requireOperationSupported('getUsers');
    final env = await _execute('getUsers', {});
    assertEnvelopeSuccess(env, 'getUsers',
        fallbackMessage: "Failed to get users");
    if (env.data is! Map) {
      throw NearpayException("Invalid data format");
    }
    return adaptUsersResult('getUsers', env.data);
  }

  Future<String> logout({required String userUUID}) async {
    final env = await _execute('logout', {'userUUID': userUUID});
    assertEnvelopeSuccess(env, 'logout', fallbackMessage: "Failed to logout");
    return env.message ?? '';
  }

  Future<TerminalModel> getTerminal({required String terminalUUID}) async {
    final env = await _execute('getTerminal', {'terminalUUID': terminalUUID});
    assertEnvelopeSuccess(env, 'getTerminal',
        fallbackMessage: "Failed to get terminal");
    return adaptTerminalModelResult('getTerminal', env.data);
  }

  Future<TerminalList> getTerminalList(String uuid,
      {int? page, int? pageSize, String? nameFilter}) async {
    final env = await _execute('getTerminalList', {
      'uuid': uuid,
      "page": page,
      "pageSize": pageSize,
      "nameFilter": nameFilter,
    });
    assertEnvelopeSuccess(env, 'getTerminalList',
        fallbackMessage: 'Failed to retrieve terminals: Unknown error');
    return adaptTerminalListResult('getTerminalList', env.data);
  }

  Future<TerminalModel> connectTerminal({
    required String tid,
    required String userUUID,
    required String terminalUUID,
    String? name,
  }) async {
    final env = await _execute('connectTerminal', {
      'tid': tid,
      'userUUID': userUUID,
      'terminalUUID': terminalUUID,
      'name': name,
    });
    assertEnvelopeSuccess(env, 'connectTerminal',
        fallbackMessage: 'Failed to connect to terminal');
    return adaptTerminalModelResult('connectTerminal', env.data);
  }

  Future<bool> disconnectTerminal() async {
    if (!_isInitialized()) {
      throw NearpayException(
          "Cannot call disconnectTerminal before initialization");
    }
    final result = await _port.invokeRaw('disconnectTerminal');

    if (result is bool) {
      return result;
    }

    if (result is Map) {
      final env = NativeEnvelope.from(result);
      assertEnvelopeSuccess(env, 'disconnectTerminal',
          fallbackMessage: "Failed to disconnect terminal");
      return true;
    }

    return result != null;
  }

  Future<String> getVersion() async {
    final result = await _port.invokeRaw('getVersion');
    if (result is String && result.isNotEmpty) {
      return result;
    }
    return 'unsupported';
  }
}
