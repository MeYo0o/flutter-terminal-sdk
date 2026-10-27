import '../../../domain/models/data/dto/proxy_room_response.dart';
import '../../mappers/native/operation_mapper.dart';
import 'adapter_utils.dart';

ProxyRoomResponse adaptCreateProxyRoomResult(String operation, Object? data) =>
    mapProxyRoomResponse(unwrapForCurrentPlatform(operation, data));
