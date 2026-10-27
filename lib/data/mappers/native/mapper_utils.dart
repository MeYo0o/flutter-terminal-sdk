/// Coerces a normalized native payload into a `Map<String, dynamic>`.
///
/// Throws (like the previous `env.data as Map<String, dynamic>` call sites) when
/// the payload is not a map, preserving the original failure behavior.
Map<String, dynamic> asResponseMap(Object? raw) =>
    Map<String, dynamic>.from(raw as Map);
