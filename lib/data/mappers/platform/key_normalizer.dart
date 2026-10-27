/// Recursive key normalization, ported from `rn-terminal-sdk`'s
/// `keyNormalizer.ts`.
///
/// Calibration note (Flutter-specific, deliberate deviation from RN):
///
/// RN's `KEY_ALIASES` renames `*Uuid -> *UUID` (and `terminalId -> terminalID`).
/// In this SDK the native Android (Kotlin `ArgsFilter`) and iOS (Swift bridge)
/// handlers expect the exact keys Dart currently sends - `authorizationUuid`,
/// `refundUuid`, `intentUUID`, `terminalUUID`, `transactionUUID`, `uuid`, `id`.
/// Renaming any of those on the outbound path would break native, and prior
/// phases froze Kotlin/Swift. The alias table is therefore intentionally EMPTY
/// so normalization never renames a key the wire protocol depends on.
///
/// What remains active is `snake_case -> camelCase` conversion, which is a safe
/// no-op for the current outbound payloads (all already camelCase) while
/// future-proofing any snake_case input. This function is only used on the
/// OUTBOUND path; inbound response data is passed through untouched so that the
/// existing model `fromJson` implementations (several of which read snake_case
/// fields) keep working - see `normalizer.dart`.
///
/// Phase 6 inbound audit (why inbound normalization stays identity):
///
/// The two native sides disagree on casing per payload, not uniformly:
///   - Android emits `snake_case` for most responses (no gson naming policy).
///   - iOS leaves most responses `snake_case` too, but the Swift bridge
///     selectively camelCases a few via `camelCaseKeysDeep` (terminal config,
///     reconciliation receipts, `performance`).
/// Because casing is divergent AND inconsistent across deeply-nested subtrees
/// (e.g. a transaction receipt is snake on both platforms, while a
/// reconciliation receipt is camel on iOS / snake on Android), turning on a
/// blanket inbound key rewrite here would rewrite whole subtrees and regress
/// the snake-on-both models. Inbound parity is therefore handled locally and
/// non-regressively at the model layer via `pickKey` (lib/models/util/json_pick.dart),
/// which reads the existing key first and the opposite casing as a fallback.
/// The per-platform inbound payload-map handlers stay identity for this reason.
const Map<String, String> kNativeKeyAliases = <String, String>{};

final RegExp _snakeBoundary = RegExp(r'_([a-zA-Z0-9])');

String _toCamelCaseKey(String key) => key.replaceAllMapped(
      _snakeBoundary,
      (match) => match.group(1)!.toUpperCase(),
    );

String _normalizeKey(String key, Map<String, String> aliases) {
  final camelKey = _toCamelCaseKey(key);
  return aliases[camelKey] ?? camelKey;
}

bool _shouldPreferCurrentValue(String rawKey) => !rawKey.contains('_');

Object? normalizeNativePayloadKeys(
  Object? value, {
  Map<String, String> aliases = kNativeKeyAliases,
}) {
  if (value is List) {
    return value
        .map((item) => normalizeNativePayloadKeys(item, aliases: aliases))
        .toList();
  }

  if (value is! Map) {
    return value;
  }

  final normalized = <String, dynamic>{};
  value.forEach((rawKey, rawValue) {
    final key = rawKey is String ? rawKey : rawKey.toString();
    final mappedKey = _normalizeKey(key, aliases);
    final mappedValue = normalizeNativePayloadKeys(rawValue, aliases: aliases);

    if (normalized.containsKey(mappedKey) && !_shouldPreferCurrentValue(key)) {
      return;
    }
    normalized[mappedKey] = mappedValue;
  });
  return normalized;
}
