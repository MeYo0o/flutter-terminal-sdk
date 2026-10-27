class InitializationEventPayload {
  final String status;
  final String? message;

  const InitializationEventPayload({required this.status, this.message});
}

class LogoutEventPayload {
  final String userUUID;

  const LogoutEventPayload({required this.userUUID});
}

class TerminalDisconnectEventPayload {
  final String terminalUUID;

  const TerminalDisconnectEventPayload({required this.terminalUUID});
}
