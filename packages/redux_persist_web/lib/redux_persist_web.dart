import 'dart:async';
import 'dart:html';

import 'package:redux_persist/redux_persist.dart';

/// Storage engine to use with Flutter
class WebStorage implements StorageEngine {
  final String key;

  WebStorage(this.key);

  @override
  load() {
    return new Future.value(window.localStorage[key]);
  }

  @override
  save(String json) {
    window.localStorage[key] = json;
  }
}
