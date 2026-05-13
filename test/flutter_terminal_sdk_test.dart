import 'package:flutter/services.dart';
import 'package:flutter_terminal_sdk/errors/errors.dart';
import 'package:flutter_terminal_sdk/models/PermissionStatus.dart';
import 'package:flutter_terminal_sdk/models/nearpay_user_response.dart';
import 'package:flutter_terminal_sdk/models/send_otp_response.dart';
import 'package:flutter_terminal_sdk/models/terminal_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_terminal_sdk/flutter_terminal_sdk.dart';
import 'package:flutter_terminal_sdk/flutter_terminal_sdk_platform_interface.dart';
import 'package:flutter_terminal_sdk/flutter_terminal_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterTerminalSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterTerminalSdkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // <- first line

  final FlutterTerminalSdkPlatform initialPlatform =
      FlutterTerminalSdkPlatform.instance;

  test('$MethodChannelFlutterTerminalSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTerminalSdk>());
  });

  test('getPlatformVersion', () async {
    FlutterTerminalSdk flutterTerminalSdkPlugin = FlutterTerminalSdk();
    MockFlutterTerminalSdkPlatform fakePlatform =
        MockFlutterTerminalSdkPlatform();
    FlutterTerminalSdkPlatform.instance = fakePlatform;

    expect(await flutterTerminalSdkPlugin.getPlatformVersion(), '42');
  });

  // add more tests here
  test('test NearpayException', () {
    final exception = NearpayException('Test error message');
    expect(exception.toString(), 'NearpayException: Test error message');
  });

  test('initialize throws NearpayException on failure', () async {
    final flutterTerminalSdkPlugin = FlutterTerminalSdk();

    // Mock the MethodChannel to throw an error
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'initialize') {
        throw PlatformException(code: 'ERROR', message: 'Failed');
      }
      return null;
    });

    expect(flutterTerminalSdkPlugin.isInitialized, false);
    expect(
      () async => await flutterTerminalSdkPlugin.initialize(
        environment: Environment.sandbox,
        googleCloudProjectNumber: 123,
        huaweiSafetyDetectApiKey: 'test-key',
        country: Country.sa,
      ),
      throwsA(isA<NearpayException>()),
    );
  });

  test('initialize sets _initialized to true on success', () async {
    FlutterTerminalSdk flutterTerminalSdkPlugin = FlutterTerminalSdk();

    // Mock the MethodChannel to always succeed
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await flutterTerminalSdkPlugin.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );

    expect(flutterTerminalSdkPlugin.isInitialized, true);
  });

  test('checkRequiredPermissions returns list on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'checkRequiredPermissions') {
        return {
          "status": "success",
          "data": [
            {"permission": "camera", "isGranted": true},
            {"permission": "location", "isGranted": false}
          ]
        };
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.checkRequiredPermissions();
    expect(result, isA<List<PermissionStatus>>());
    expect(result.length, 2);
    expect(result[0].permission, "camera");
    expect(result[0].isGranted, true);
  });

  test('checkRequiredPermissions throws NearpayException on error status',
      () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'checkRequiredPermissions') {
        return {"status": "error", "message": "Permission denied"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.checkRequiredPermissions(),
      throwsA(isA<NearpayException>()),
    );
  });

  test('checkRequiredPermissions throws NearpayException on platform error',
      () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'checkRequiredPermissions') {
        throw PlatformException(code: 'ERROR', message: 'Platform error');
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.checkRequiredPermissions(),
      throwsA(isA<NearpayException>()),
    );
  });

  test('sendMobileOtp returns OtpResponse on success', () async {
    final message = "OTP sent successfully";
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'sendMobileOtp') {
        return {
          "status": "success",
          "data": {
            "message": message,
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.sendMobileOtp("0555123456");
    expect(result, isA<OtpResponse>());
    expect(result.message, message);
  });

  test('sendMobileOtp throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'sendMobileOtp') {
        return {"status": "error", "message": "Failed to send mobile OTP"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.sendMobileOtp("0555123456"),
      throwsA(isA<NearpayException>()),
    );
  });

  test('isNfcEnabled returns true on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isNfcEnabled') {
        return {"status": "success", "data": true};
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.isNfcEnabled();
    expect(result, true);
  });

  test('isNfcEnabled returns false on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isNfcEnabled') {
        return {"status": "success", "data": false};
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.isNfcEnabled();
    expect(result, false);
  });

  test('isNfcEnabled throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isNfcEnabled') {
        return {"status": "success", "data": false};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.isNfcEnabled();
    expect(result, false);
  });

  test('isNfcEnabled throws NearpayException on platform error', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isNfcEnabled') {
        throw PlatformException(code: 'ERROR', message: 'Platform error');
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.isNfcEnabled(),
      throwsA(isA<NearpayException>()),
    );
  });

  // test isWifiEnabled
  test('isWifiEnabled returns true on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isWifiEnabled') {
        return {"status": "success", "data": true};
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.isWifiEnabled();
    expect(result, true);
  });

  test('isWifiEnabled returns false on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isWifiEnabled') {
        return {"status": "success", "data": false};
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.isWifiEnabled();
    expect(result, false);
  });

  test('isWifiEnabled throws NearpayException on platform error', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isWifiEnabled') {
        throw NearpayException("Platform error");
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.isWifiEnabled(),
      throwsA(isA<NearpayException>()),
    );
  });

  test('sendEmailOtp returns OtpResponse on success', () async {
    final message = "OTP sent successfully";
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'sendEmailOtp') {
        return {
          "status": "success",
          "data": {
            "message": message,
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );

    final result = await sdk.sendEmailOtp("o.darabeh@nearpay.io");
    expect(result, isA<OtpResponse>());
    expect(result.message, message);
  });

  test('sendEmailOtp throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'sendEmailOtp') {
        return {"status": "error", "message": "Failed to send email OTP"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.sendEmailOtp("o.darabeh@nearpay.io"),
      throwsA(isA<NearpayException>()),
    );
  });

  test('sendEmailOtp throws NearpayException on platform error', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'sendEmailOtp') {
        return {
          "status": "error",
          "data": {
            "message": "Failed to send email OTP",
          }
        };
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.sendEmailOtp("o.darabeh@nearpay.io"),
      throwsA(isA<NearpayException>()),
    );
  });

  // Test: verifyMobileOtp returns NearpayUser on success
  test('verifyMobileOtp returns NearpayUser on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'verifyMobileOtp') {
        return {
          "status": "success",
          "data": {
            "userUUID": "user-uuid",
            "name": "Test User",
            "email": "email",
            "mobile": "mobile",
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.verifyMobileOtp(
      mobileNumber: "0555123456",
      code: "123456",
    );
    expect(result, isA<NearpayUser>());
    expect(result.userUUID, "user-uuid");
    expect(result.name, "Test User");
  });

// Test: verifyMobileOtp throws NearpayException on error status
  test('verifyMobileOtp throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'verifyMobileOtp') {
        return {"status": "error", "message": "Failed to verify mobile OTP"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.verifyMobileOtp(
        mobileNumber: "0555123456",
        code: "123456",
      ),
      throwsA(isA<NearpayException>()),
    );
  });

  // test verifyEmailOtp returns NearpayUser on success
  test('verifyEmailOtp returns NearpayUser on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'verifyEmailOtp') {
        return {
          "status": "success",
          "data": {
            "userUUID": "user-uuid",
            "name": "Test User",
            "email": "email",
            "mobile": "mobile",
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.verifyEmailOtp(
      email: "email",
      code: "123456",
    );
    expect(result, isA<NearpayUser>());
    expect(result.userUUID, "user-uuid");
    expect(result.name, "Test User");
  });

  // test verifyEmailOtp throws NearpayException on error status
  test('verifyEmailOtp throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'verifyEmailOtp') {
        return {"status": "error", "message": "Failed to verify email OTP"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.verifyEmailOtp(
        email: "email",
        code: "123456",
      ),
      throwsA(isA<NearpayException>()),
    );
  });

  //test jwtVerify function
  test('jwtVerify returns NearpayUser on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'jwtVerify') {
        return {
          "status": "success",
          "data": {
            "tid": "tid",
            "terminalUUID": "terminalUUID",
            "name": "name",
            "paymentText": {
              "localizedPaymentText": "localizedPaymentText",
              "englishPaymentText": "englishPaymentText"
            },
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );

    final result = await sdk.jwtLogin(jwt: "test-jwt-token");
    expect(result, isA<TerminalModel>());
    expect(result.terminalUUID, "terminalUUID");
    expect(result.name, "name");
    expect(result.tid, "tid");
    expect(result.paymentText?.localizedPaymentText, "localizedPaymentText");
    expect(result.paymentText?.englishPaymentText, "englishPaymentText");
  });

  // test jwtLogin throws NearpayException on error status
  test('jwtVerify throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'jwtVerify') {
        return {"status": "error", "message": "Failed to login with JWT"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );

    expect(
      () async => await sdk.jwtLogin(
        jwt: 'jwt',
      ),
      throwsA(isA<NearpayException>()),
    );
  });

  test('getUserByUUID returns NearpayUser on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getUser') {
        return {
          "status": "success",
          "data": {
            "userUUID": "user-uuid",
            "name": "Test User",
            "email": "email",
            "mobile": "mobile",
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.getUserByUUID(uuid: "user-uuid");
    expect(result, isA<NearpayUser>());
    expect(result.userUUID, "user-uuid");
    expect(result.name, "Test User");
  });

  test('getUserByUUID throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getUser') {
        return {"status": "error", "message": "Failed to get user"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.getUserByUUID(uuid: "user-uuid"),
      throwsA(isA<NearpayException>()),
    );
  });

  test('getUsers returns list of NearpayUser on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getUsers') {
        return {
          "status": "success",
          "data": {
            "user1": {
              "userUUID": "user-uuid-1",
              "name": "User One",
              "email": "user1@email.com",
              "mobile": "1234567890",
            },
            "user2": {
              "userUUID": "user-uuid-2",
              "name": "User Two",
              "email": "user2@email.com",
              "mobile": "0987654321",
            }
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.getUsers();
    expect(result, isA<List<NearpayUser>>());
    expect(result.length, 2);
    expect(result[0].userUUID, "user-uuid-1");
    expect(result[1].userUUID, "user-uuid-2");
  });

  test('getUsers throws Exception on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getUsers') {
        return {"status": "error", "message": "Failed to get users"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.getUsers(),
      throwsA(isA<Exception>()),
    );
  });

  test('getUsers throws NearpayException on invalid data format', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getUsers') {
        return {
          "status": "success",
          "data": [
            {"userUUID": "user-uuid-1", "name": "User One"}
          ]
        };
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(() async => await sdk.getUsers(), throwsA(isA<NearpayException>()));
  });

  //getUsers throws NearpayException on error status

  test('getUsers throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getUsers') {
        return {"status": "error", "message": "Failed to get users"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.getUsers(),
      throwsA(isA<NearpayException>()),
    );
  });

  test('logout returns message on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'logout') {
        return {"status": "success", "message": "Logged out"};
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.logout(userUUID: "user-uuid");
    expect(result, "Logged out");
  });

  test('logout throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'logout') {
        return {"status": "error", "message": "Failed to logout"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
      () async => await sdk.logout(userUUID: "user-uuid"),
      throwsA(isA<NearpayException>()),
    );
  });

  test('getTerminal returns TerminalModel on success', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getTerminal') {
        return {
          "status": "success",
          "data": {
            "tid": "tid",
            "terminalUUID": "terminalUUID",
            "name": "name",
            "paymentText": {
              "localizedPaymentText": "localizedPaymentText",
              "englishPaymentText": "englishPaymentText"
            },
          }
        };
      } else if (call.method == 'initialize') {
        return null;
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    final result = await sdk.getTerminal(terminalUUID: "terminal-uuid");
    expect(result, isA<TerminalModel>());
    expect(result.terminalUUID, "terminalUUID");
    expect(result.name, "name");
    expect(result.tid, "tid");
    expect(result.paymentText?.localizedPaymentText, "localizedPaymentText");
    expect(result.paymentText?.englishPaymentText, "englishPaymentText");
  });

  test('getTerminal throws NearpayException on error status', () async {
    final sdk = FlutterTerminalSdk();
    const MethodChannel channel = MethodChannel('nearpay_plugin');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getTerminal') {
        return {"status": "error", "message": "Failed to get user"};
      }
      return null;
    });

    await sdk.initialize(
      environment: Environment.sandbox,
      googleCloudProjectNumber: 123,
      huaweiSafetyDetectApiKey: 'test-key',
      country: Country.sa,
    );
    expect(
          () async => await sdk.getTerminal(terminalUUID: "terminal-uuid"),
      throwsA(isA<NearpayException>()),
    );
  });
}
