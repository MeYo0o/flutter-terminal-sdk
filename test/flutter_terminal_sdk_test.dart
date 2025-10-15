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
  final FlutterTerminalSdkPlatform initialPlatform = FlutterTerminalSdkPlatform.instance;

  test('$MethodChannelFlutterTerminalSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterTerminalSdk>());
  });

  test('getPlatformVersion', () async {
    FlutterTerminalSdk flutterTerminalSdkPlugin = FlutterTerminalSdk();
    MockFlutterTerminalSdkPlatform fakePlatform = MockFlutterTerminalSdkPlatform();
    FlutterTerminalSdkPlatform.instance = fakePlatform;

    expect(await flutterTerminalSdkPlugin.getPlatformVersion(), '42');
  });
}
