import '../../../domain/models/PermissionStatus.dart';
import '../../../domain/models/nearpay_user_response.dart';
import '../../../domain/models/send_otp_response.dart';
import '../../mappers/native/auth_mapper.dart';
import 'adapter_utils.dart';

OtpResponse adaptOtpResult(String operation, Object? data) =>
    mapOtpResponse(unwrapForCurrentPlatform(operation, data));

NearpayUser adaptUserResult(String operation, Object? data) =>
    mapNearpayUser(unwrapForCurrentPlatform(operation, data));

List<NearpayUser> adaptUsersResult(String operation, Object? data) =>
    mapUsersList(unwrapForCurrentPlatform(operation, data));

List<PermissionStatus> adaptPermissionStatusResult(
        String operation, Object? data) =>
    mapPermissionStatusList(unwrapForCurrentPlatform(operation, data));
