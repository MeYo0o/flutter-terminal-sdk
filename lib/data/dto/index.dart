/// Top-level barrel for native DTO wire-shapes (parity with rn-terminal-sdk
/// `data/dto/index`).
///
/// RN namespaces these as `SharedDto` / `AndroidDto` / `IosDto`. Dart barrels
/// re-export directly; the platform-prefixed type names keep them collision-free.
/// Import a single platform barrel with a prefix to mirror RN's namespacing,
/// e.g. `import 'package:flutter_terminal_sdk/data/dto/shared/index.dart' as shared_dto;`.
library;

export 'shared/index.dart';
export 'android/index.dart';
export 'ios/index.dart';
