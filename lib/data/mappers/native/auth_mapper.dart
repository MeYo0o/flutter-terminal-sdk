import '../../../domain/models/PermissionStatus.dart';
import '../../../domain/models/nearpay_user_response.dart';
import '../../../domain/models/send_otp_response.dart';
import 'mapper_utils.dart';

OtpResponse mapOtpResponse(Object? raw) =>
    OtpResponse.fromJson(asResponseMap(raw));

NearpayUser mapNearpayUser(Object? raw) =>
    NearpayUser.fromJson(asResponseMap(raw));

List<NearpayUser> mapUsersList(Object? raw) {
  if (raw is! Map) {
    return const [];
  }
  final users = <NearpayUser>[];
  raw.forEach((key, value) {
    if (value is Map) {
      users.add(NearpayUser.fromJson(Map<String, dynamic>.from(value)));
    }
  });
  return users;
}

List<PermissionStatus> mapPermissionStatusList(Object? raw) => (raw as List)
    .map<PermissionStatus>((p) => PermissionStatus.fromJson(p))
    .toList();
