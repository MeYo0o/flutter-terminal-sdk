import '../../common/native_payload.dart';
import '../../sources/native/method_channel_native_source.dart';

Object? unwrapForCurrentPlatform(String operation, Object? data) =>
    unwrapNativePayload(
      operation,
      data,
      isIOS: MethodChannelNativeSource.instance.isIOS,
    );
