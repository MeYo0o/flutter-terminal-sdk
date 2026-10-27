import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../domain/ports/nearpay_native_port.dart';
import '../../../helper/platform_support.dart';
import '../../mappers/platform/normalizer.dart';
import '../../native/listener_set.dart';
import '../../native/native_envelope.dart';

class MethodChannelNativeSource implements NearpayNativePort {
  MethodChannelNativeSource._()
      : _channel = const MethodChannel('nearpay_plugin') {
    _channel.setMethodCallHandler(_dispatch);
  }

  static final MethodChannelNativeSource instance =
      MethodChannelNativeSource._();

  final MethodChannel _channel;

  final ListenerSet<MethodCall> _methodCallListeners =
      ListenerSet<MethodCall>();

  @override
  bool get isIOS => isIOSPlatform;

  @override
  bool get isAndroid => isAndroidPlatform;

  @override
  Future<NativeEnvelope> execute(String operation, [dynamic payload]) async {
    final raw =
        await _channel.invokeMethod(operation, normalizePayload(payload));
    return NativeEnvelope.from(raw);
  }

  @override
  Future<dynamic> invokeRaw(String operation, [dynamic payload]) {
    return _channel.invokeMethod(operation, normalizePayload(payload));
  }

  @override
  NativeUnsubscribe addMethodCallListener(NativeMethodCallHandler handler) {
    return _methodCallListeners.add((call) {
      handler(call);
    });
  }

  @override
  void setMethodCallHandler(NativeMethodCallHandler? handler) {
    if (handler == null) {
      _methodCallListeners.clear();
      return;
    }
    addMethodCallListener(handler);
  }

  Future<dynamic> _dispatch(MethodCall call) async {
    if (kDebugMode) {
      debugPrint('NearpayNative <= ${call.method}');
    }
    _methodCallListeners.emit(call);
    return null;
  }
}
