typedef NfcShareFailureType = String;

class NfcShareFailure {
  final NfcShareFailureType type;
  final String? message;

  const NfcShareFailure({
    required this.type,
    this.message,
  });
}

class NfcShareCallbacks {
  final void Function()? onStarted;
  final void Function()? onShared;
  final void Function()? onStopped;
  final void Function(NfcShareFailure failure)? onFailure;

  const NfcShareCallbacks({
    this.onStarted,
    this.onShared,
    this.onStopped,
    this.onFailure,
  });
}

class NfcShareStartParams {
  final String url;
  final int? timeoutMillis;
  final String? sessionId;
  final NfcShareCallbacks? callbacks;

  const NfcShareStartParams({
    required this.url,
    this.timeoutMillis,
    this.sessionId,
    this.callbacks,
  });
}

class NfcShareStartResult {
  final bool started;
  final String sessionId;

  const NfcShareStartResult({
    required this.started,
    required this.sessionId,
  });
}

NfcShareFailure parseNfcShareFailure(Object? data) {
  if (data is! Map) {
    return const NfcShareFailure(
      type: 'GeneralFailure',
      message: 'Unknown NFC share failure',
    );
  }
  final record = Map<String, dynamic>.from(data);
  final type = record['type']?.toString() ?? 'GeneralFailure';
  final message = record['message']?.toString();
  return NfcShareFailure(type: type, message: message);
}
