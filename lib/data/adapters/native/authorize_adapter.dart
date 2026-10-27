import '../../../domain/models/data/authorize_response.dart';
import '../../../domain/models/data/capture_response.dart';
import '../../../domain/models/data/increment_response.dart';
import '../../../domain/models/data/void_authorization_response.dart';
import '../../mappers/native/authorize_mapper.dart';
import 'adapter_utils.dart';

AuthorizeResponse adaptAuthorizeResult(String operation, Object? data) =>
    mapAuthorizeResponse(unwrapForCurrentPlatform(operation, data));

CaptureResponse adaptCaptureResult(String operation, Object? data) =>
    mapCaptureResponse(unwrapForCurrentPlatform(operation, data));

VoidAuthorizationResponse adaptVoidAuthorizationResult(
        String operation, Object? data) =>
    mapVoidAuthorizationResponse(unwrapForCurrentPlatform(operation, data));

IncrementResponse adaptIncrementResult(String operation, Object? data) =>
    mapIncrementResponse(unwrapForCurrentPlatform(operation, data));
