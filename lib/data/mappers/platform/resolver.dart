import 'android/index.dart';
import 'ios/index.dart';
import 'native_payload_map.dart';

NativeOperationPayloadMap resolveNativePayloadMapper(bool isIOS) =>
    isIOS ? iosOperationPayloadMap : androidOperationPayloadMap;
