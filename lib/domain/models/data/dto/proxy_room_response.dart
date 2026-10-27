import '../../util/json_pick.dart';

class ProxyRoomResponse {
  final String roomId;
  final String token;
  final bool pairingCodeIsUsed;

  ProxyRoomResponse({
    required this.roomId,
    required this.token,
    required this.pairingCodeIsUsed,
  });

  factory ProxyRoomResponse.fromJson(Map<String, dynamic> json) {
    final roomId = toStringSafe(pickKey(json, ['roomId', 'room_id'])).trim();
    final token = toStringSafe(pickKey(json, ['token'])).trim();
    if (roomId.isEmpty || token.isEmpty) {
      throw StateError('Invalid createProxyRoom response');
    }
    return ProxyRoomResponse(
      roomId: roomId,
      token: token,
      pairingCodeIsUsed: toBoolSafe(
        pickKey(json, ['pairingCodeIsUsed', 'pairing_code_is_used']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'token': token,
        'pairingCodeIsUsed': pairingCodeIsUsed,
      };
}
