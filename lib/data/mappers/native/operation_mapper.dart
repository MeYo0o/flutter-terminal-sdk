import '../../../domain/models/data/dto/proxy_room_response.dart';
import '../../../domain/models/util/json_pick.dart';
import 'mapper_utils.dart';

String mapPendingTotal(Object? raw) {
  if (raw is String) return raw;
  if (raw is Map) {
    final value = pickKey(raw, ['pendingTotal', 'pending_total', 'total']);
    if (value != null) return toStringSafe(value);
  }
  throw StateError('Invalid pending total response');
}

ProxyRoomResponse mapProxyRoomResponse(Object? raw) =>
    ProxyRoomResponse.fromJson(asResponseMap(raw));
