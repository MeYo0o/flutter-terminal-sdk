import '../../errors/errors.dart';
import 'callbacks.dart' show VoidCallback;

enum LinkingEventType {
  linkingStarted,
  linkingProgress,
  linkingCompleted,
  linkingFailure,
}

enum LinkingProvider { apple, nearpay }

class LinkingEventData {
  const LinkingEventData({
    this.provider,
    this.state,
    this.progress,
    this.nativeError,
  });

  final LinkingProvider? provider;
  final String? state;
  final int? progress;
  final Map<String, dynamic>? nativeError;

  factory LinkingEventData.fromMap(Map<String, dynamic>? raw) {
    if (raw == null) return const LinkingEventData();
    LinkingProvider? provider;
    final providerRaw = raw['provider'];
    if (providerRaw == 'apple') {
      provider = LinkingProvider.apple;
    } else if (providerRaw == 'nearpay') {
      provider = LinkingProvider.nearpay;
    }
    final progressRaw = raw['progress'];
    return LinkingEventData(
      provider: provider,
      state: raw['state'] as String?,
      progress: progressRaw is num ? progressRaw.toInt() : null,
      nativeError: raw['nativeError'] is Map
          ? Map<String, dynamic>.from(raw['nativeError'] as Map)
          : null,
    );
  }
}

class LinkingCallbackEventPayload {
  const LinkingCallbackEventPayload({
    required this.type,
    required this.normalizedType,
    this.message,
    this.data,
  });

  final String type;
  final LinkingEventType normalizedType;
  final String? message;
  final LinkingEventData? data;
}

typedef LinkingExceptionCallback = void Function(NearpayException error);
typedef LinkingEventCallback = void Function(LinkingCallbackEventPayload event);
typedef LinkingProgressCallback = void Function(int progress);
typedef LinkingDataCallback = void Function(LinkingEventData? data);

class LinkingCallbacks {
  const LinkingCallbacks({
    this.onLinkingStarted,
    this.onPreparingToLink,
    this.onLinkingProgress,
    this.onLinkingCompleted,
    this.onNearpayException,
    this.onRelinking,
    this.onLinkingEvent,
  });

  final VoidCallback? onLinkingStarted;
  final LinkingDataCallback? onPreparingToLink;
  final LinkingProgressCallback? onLinkingProgress;
  final LinkingDataCallback? onLinkingCompleted;
  final LinkingExceptionCallback? onNearpayException;
  final LinkingDataCallback? onRelinking;
  final LinkingEventCallback? onLinkingEvent;
}

const _linkingEventAliases = {
  'onLinkingStarted': 'linkingStarted',
  'onLinkingProgress': 'linkingProgress',
  'onLinkingCompleted': 'linkingCompleted',
  'onLinkingFailure': 'linkingFailure',
  'linkingSuccess': 'linkingCompleted',
  'linkingFailed': 'linkingFailure',
  'preparingToLink': 'linkingStarted',
  'relinking': 'linkingStarted',
};

LinkingEventType? normalizeLinkingEventType(String? type) {
  final value = (type ?? '').trim();
  if (value.isEmpty) return null;
  final normalized = _linkingEventAliases[value] ?? value;
  switch (normalized) {
    case 'linkingStarted':
      return LinkingEventType.linkingStarted;
    case 'linkingProgress':
      return LinkingEventType.linkingProgress;
    case 'linkingCompleted':
      return LinkingEventType.linkingCompleted;
    case 'linkingFailure':
      return LinkingEventType.linkingFailure;
    default:
      return null;
  }
}

bool isLinkingEventType(String? type) =>
    normalizeLinkingEventType(type) != null;

bool dispatchLinkingCallbacks(
  LinkingCallbacks? callbacks, {
  required String type,
  String? message,
  Map<String, dynamic>? data,
}) {
  final normalizedType = normalizeLinkingEventType(type);
  if (normalizedType == null) {
    return false;
  }

  final eventData =
      data != null ? LinkingEventData.fromMap(data) : const LinkingEventData();
  final payload = LinkingCallbackEventPayload(
    type: type,
    normalizedType: normalizedType,
    message: message,
    data: eventData,
  );

  callbacks?.onLinkingEvent?.call(payload);

  if (type == 'relinking') {
    callbacks?.onRelinking?.call(eventData);
    return true;
  }

  switch (normalizedType) {
    case LinkingEventType.linkingStarted:
      callbacks?.onLinkingStarted?.call();
      final state = eventData.state ??
          (type == 'preparingToLink'
              ? 'preparingToLink'
              : type == 'relinking'
                  ? 'relinking'
                  : null);
      if (state == 'preparingToLink') {
        callbacks?.onPreparingToLink?.call(eventData);
      }
      if (state == 'relinking') {
        callbacks?.onRelinking?.call(eventData);
      }
      return true;
    case LinkingEventType.linkingProgress:
      final progress = eventData.progress;
      callbacks?.onLinkingProgress?.call(
        progress != null && progress >= 0 ? progress : 0,
      );
      return true;
    case LinkingEventType.linkingCompleted:
      callbacks?.onLinkingCompleted?.call(eventData);
      return true;
    case LinkingEventType.linkingFailure:
      final resolvedMessage = (message != null && message.trim().isNotEmpty)
          ? message.trim()
          : 'Linking failed';
      callbacks?.onNearpayException?.call(
        NearpayException(resolvedMessage, type: 'LINKING_FAILURE'),
      );
      return true;
  }
}

String resolveTerminalLinkingEventId(Map<String, dynamic> args) {
  for (final key in const ['terminalUUID', 'terminalUuid', 'uuid']) {
    final value = args[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim().toLowerCase();
    }
  }
  return '';
}
