import '../../errors/errors.dart';
import '../../errors/nearpay_native_error.dart';
import 'native_envelope.dart';

NearpayException getNativeOperationError(
  String operation,
  NativeEnvelope env, {
  required String fallbackMessage,
}) {
  final envMessage = env.message?.trim();
  final message = (envMessage != null && envMessage.isNotEmpty)
      ? envMessage
      : fallbackMessage;
  final type = env.type ?? env.code;
  final nativeError =
      normalizeToNativeErrorModel(message, type, env.nativeError) ??
          NearpayNativeError.minimal(type ?? 'OPERATION_FAILURE', message);

  return NearpayException(
    message,
    type: type,
    code: env.code,
    nativeError: nativeError,
  );
}

void assertEnvelopeSuccess(
  NativeEnvelope env,
  String operation, {
  required String fallbackMessage,
}) {
  if (env.status != null && !env.isSuccess) {
    throw getNativeOperationError(operation, env,
        fallbackMessage: fallbackMessage);
  }
}
