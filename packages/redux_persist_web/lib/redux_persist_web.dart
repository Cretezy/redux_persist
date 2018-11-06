library redux_persist_web;

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:redux_persist/redux_persist.dart';

/// Storage engine to use with Web.
/// You should only store utf8-encoded data here, like JSON, or base64 data.
class WebStorage implements StorageEngine {
  /// localStorage key to save to.
  final String key;

  WebStorage([this.key = "app"]);

  @override
  Future<Uint8List> load() =>
      Future.value(stringToUint8List(window.localStorage[key]));

  @override
  Future<void> save(Uint8List data) async {
    window.localStorage[key] = uint8ListToString(data);
  }
}
