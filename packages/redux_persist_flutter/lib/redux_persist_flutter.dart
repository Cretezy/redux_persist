library redux_persist_flutter;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Location to save state when using Flutter.
enum FlutterSaveLocation {
  /// Maps to DocumentFileEngine.
  documentFile,

  /// Maps to SharedPreferencesEngine.
  sharedPreferences,
}

/// Storage engine to use with Flutter.
/// Proxy of SharedPreferenceEngine and DocumentFileEngine.
class FlutterStorage implements StorageEngine {
  late StorageEngine _locationEngine;

  FlutterStorage({
    String key = "app",
    FlutterSaveLocation location = FlutterSaveLocation.documentFile,
  }) {
    switch (location) {
      case FlutterSaveLocation.documentFile:
        _locationEngine = DocumentFileEngine(key);
        break;
      case FlutterSaveLocation.sharedPreferences:
        _locationEngine = SharedPreferencesEngine(key);
        break;
      default:
        throw StorageException("No Flutter storage location");
    }
  }

  @override
  Future<Uint8List?> load() => _locationEngine.load();

  @override
  Future<void> save(Uint8List? json) => _locationEngine.save(json);
}

/// Storage engine to save to application document directory.
class DocumentFileEngine implements StorageEngine {
  /// File name to save to.
  final String key;

  DocumentFileEngine([this.key = "app"]);

  @override
  Future<Uint8List?> load() async {
    final file = await _getFile();

    if (await file.exists()) {
      // Read to json
      return Uint8List.fromList(await file.readAsBytes());
    }

    return null;
  }

  @override
  Future<void> save(Uint8List? data) async {
    final file = await _getFile();
    // Write as json
    await file.writeAsBytes(data!);
  }

  Future<File> _getFile() async {
    // Use the Flutter app documents directory
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/persist_$key.json');
  }
}

/// Storage engine to save to NSUserDefaults/SharedPreferences.
/// You should only store utf8-encoded data here, like JSON, or base64 data.
class SharedPreferencesEngine implements StorageEngine {
  /// Shared preferences key to save to.
  final String key;

  SharedPreferencesEngine([this.key = "app"]);

  @override
  Future<Uint8List?> load() async {
    final sharedPreferences = await _getSharedPreferences();
    return stringToUint8List(sharedPreferences.getString(key));
  }

  @override
  Future<void> save(Uint8List? data) async {
    final sharedPreferences = await _getSharedPreferences();
    sharedPreferences.setString(key, uint8ListToString(data)!);
  }

  Future<SharedPreferences> _getSharedPreferences() async =>
      await SharedPreferences.getInstance();
}
