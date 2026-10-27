import 'package:flutter/services.dart';

import '../../data/native/native_envelope.dart';

typedef NativeMethodCallHandler = Future<dynamic> Function(MethodCall call);

typedef NativeUnsubscribe = void Function();

abstract class NearpayNativePort {
  bool get isIOS;
  bool get isAndroid;

  Future<NativeEnvelope> execute(String operation, [dynamic payload]);

  Future<dynamic> invokeRaw(String operation, [dynamic payload]);

  NativeUnsubscribe addMethodCallListener(NativeMethodCallHandler handler);

  void setMethodCallHandler(NativeMethodCallHandler? handler);
}
