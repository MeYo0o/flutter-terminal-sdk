import 'package:flutter/foundation.dart';

import '../errors/errors.dart';

bool get isIOSPlatform => defaultTargetPlatform == TargetPlatform.iOS;

bool get isAndroidPlatform => defaultTargetPlatform == TargetPlatform.android;

void requireAndroidFeature(String message) {
  if (isIOSPlatform) {
    throw NearpayException(message);
  }
}

void requireIosFeature(String message) {
  if (isAndroidPlatform) {
    throw NearpayException(message);
  }
}
