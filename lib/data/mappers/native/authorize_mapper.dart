import '../../../domain/models/data/authorize_response.dart';
import '../../../domain/models/data/capture_response.dart';
import '../../../domain/models/data/increment_response.dart';
import '../../../domain/models/data/void_authorization_response.dart';
import 'mapper_utils.dart';

AuthorizeResponse mapAuthorizeResponse(Object? raw) =>
    AuthorizeResponse.fromJson(asResponseMap(raw));

CaptureResponse mapCaptureResponse(Object? raw) =>
    CaptureResponse.fromJson(asResponseMap(raw));

VoidAuthorizationResponse mapVoidAuthorizationResponse(Object? raw) =>
    VoidAuthorizationResponse.fromJson(asResponseMap(raw));

IncrementResponse mapIncrementResponse(Object? raw) =>
    IncrementResponse.fromJson(asResponseMap(raw));
