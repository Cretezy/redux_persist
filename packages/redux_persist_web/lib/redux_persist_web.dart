library redux_persist_web;

import 'dart:async';
import 'dart:html';

import 'package:redux_persist/redux_persist.dart';

/// Storage engine to use with Web
class WebStorage implements StorageEngine {
  final String key;

  WebStorage(this.key);

  @override
  load() => new Future.value(window.localStorage[key]);

  @override
  save(String json) {
    window.localStorage[key] = json;
  }
}
