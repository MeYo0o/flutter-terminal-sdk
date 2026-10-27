// Enum representing UI dock positions, Dart version
/// Mirrors io.nearpay.softpos.reader_ui.UiDockPosition
/// and provides Android Gravity-compatible ints for native interop.
enum UiDockPosition {
  BOTTOM_LEFT,
  BOTTOM_CENTER,
  BOTTOM_RIGHT,
  TOP_LEFT,
  TOP_CENTER,
  TOP_RIGHT,
  ABSOLUTE_CENTER,
  CENTER_LEFT,
  CENTER_RIGHT;

  bool get isBottom =>
      this == UiDockPosition.BOTTOM_LEFT ||
      this == UiDockPosition.BOTTOM_CENTER ||
      this == UiDockPosition.BOTTOM_RIGHT;

  int get gravityAndroid {
    switch (this) {
      case UiDockPosition.BOTTOM_LEFT:
        return 80 | 3;
      case UiDockPosition.BOTTOM_CENTER:
        return 80 | 1;
      case UiDockPosition.BOTTOM_RIGHT:
        return 80 | 5;
      case UiDockPosition.TOP_LEFT:
        return 48 | 3;
      case UiDockPosition.TOP_CENTER:
        return 48 | 1;
      case UiDockPosition.TOP_RIGHT:
        return 48 | 5;
      case UiDockPosition.ABSOLUTE_CENTER:
        return 17;
      case UiDockPosition.CENTER_LEFT:
        return 16 | 3;
      case UiDockPosition.CENTER_RIGHT:
        return 16 | 5;
    }
  }
}
