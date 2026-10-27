/// Generic listener registry, ported 1:1 from `rn-terminal-sdk`'s
/// `internal/listenerSet.ts`.
///
/// Why a `Set` rather than a `List`?
///   - O(1) removal instead of O(n) filtering on every disposer call.
///   - Adding the same callback reference twice does not register it twice.
///
/// Why snapshot iteration in [emit]?
///   A listener is allowed to subscribe / unsubscribe while it is being
///   notified (e.g. a one-shot handler that disposes itself). Iterating a
///   `Set` mutated mid-iteration is fragile, so we copy first.
typedef Listener<T> = void Function(T payload);

class ListenerSet<T> {
  final Set<Listener<T>> _listeners = <Listener<T>>{};

  void Function() add(Listener<T> listener) {
    _listeners.add(listener);
    var disposed = false;
    return () {
      if (disposed) {
        return;
      }
      disposed = true;
      _listeners.remove(listener);
    };
  }

  void emit(T payload) {
    if (_listeners.isEmpty) {
      return;
    }
    for (final listener in _listeners.toList(growable: false)) {
      listener(payload);
    }
  }

  void clear() => _listeners.clear();

  int get size => _listeners.length;
}
