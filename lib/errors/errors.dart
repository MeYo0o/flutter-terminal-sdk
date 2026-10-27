import 'nearpay_native_error.dart';

class NearpayException implements Exception {
  final String message;

  final String? type;

  final String? code;

  final NearpayNativeError? nativeError;

  NearpayException(
    this.message, {
    this.type,
    this.code,
    this.nativeError,
  });

  @override
  String toString() => "NearpayException: $message";
}

class NativeOperationError extends NearpayException {
  NativeOperationError(super.message,
      {super.type, super.code, super.nativeError});
}

class NotInitializedError extends NearpayException {
  NotInitializedError(super.message,
      {super.type, super.code, super.nativeError});
}

class MissingArgumentError extends NearpayException {
  MissingArgumentError(super.message,
      {super.type, super.code, super.nativeError});
}

class InvalidArgumentError extends NearpayException {
  InvalidArgumentError(super.message,
      {super.type, super.code, super.nativeError});
}

class UnsupportedOperationError extends NearpayException {
  UnsupportedOperationError(super.message,
      {super.type, super.code, super.nativeError});
}

class ResourceUnavailableError extends NearpayException {
  ResourceUnavailableError(super.message,
      {super.type, super.code, super.nativeError});
}

class OtpFailureError extends NearpayException {
  OtpFailureError(super.message, {super.type, super.code, super.nativeError});
}

class VerificationFailureError extends NearpayException {
  VerificationFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class LinkingFailureError extends NearpayException {
  LinkingFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class ProvisioningFailureError extends NearpayException {
  ProvisioningFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class NetworkFailureError extends NearpayException {
  NetworkFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class ReaderFailureError extends NearpayException {
  ReaderFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class ReadCardFailureError extends NearpayException {
  ReadCardFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class SendTransactionFailureError extends NearpayException {
  SendTransactionFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class ConnectTerminalFailureError extends NearpayException {
  ConnectTerminalFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class AuthorizationFailureError extends NearpayException {
  AuthorizationFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class OperationFailureError extends NearpayException {
  OperationFailureError(super.message,
      {super.type, super.code, super.nativeError});
}

class TransactionCancelledError extends NearpayException {
  TransactionCancelledError(super.message,
      {super.type, super.code, super.nativeError});
}

bool isNearpayException(Object? value) => value is NearpayException;

NearpayException ensureNearpayException(Object? value, [String? fallback]) {
  if (value is NearpayException) return value;
  if (value is String) return NearpayException(value);
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final message =
        (map['message'] as String?) ?? fallback ?? 'Unknown Nearpay error';
    final type = (map['type'] as String?) ?? (map['code'] as String?);
    final rawNative =
        map['nativeError'] is Map ? map['nativeError'] as Map : null;
    final nativeError = normalizeToNativeErrorModel(
          message,
          type,
          rawNative == null ? null : Map<String, dynamic>.from(rawNative),
        ) ??
        NearpayNativeError.fromUnknown(rawNative);
    return NearpayException(message, type: type, nativeError: nativeError);
  }
  return NearpayException(fallback ?? 'Unknown Nearpay error');
}

String getNearpayUserFacingMessage(Object? value, [bool? prefersArabic]) {
  final ex = ensureNearpayException(value);
  return resolveNearpayUserFacingMessage(
    ex.nativeError,
    ex.message,
    prefersArabic ?? defaultPrefersArabic(),
  );
}

bool _isCancellationText(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return normalized.contains('cancel') ||
      normalized.contains('dismiss') ||
      normalized.contains('not completed');
}

bool isCancellationError(Object? value) {
  final error = ensureNearpayException(value);
  if (_isCancellationText(error.message)) return true;
  final native = error.nativeError;
  if (native == null) return false;
  final text = native.params.values.map((v) => v?.toString() ?? '').join(' ');
  return _isCancellationText(text);
}
