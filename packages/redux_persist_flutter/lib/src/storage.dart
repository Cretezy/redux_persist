import 'dart:async';
import 'dart:io';

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
  StorageEngine locationEngine;

  FlutterStorage(String key,
      {FlutterSaveLocation location = FlutterSaveLocation.documentFile}) {
    switch (location) {
      case FlutterSaveLocation.sharedPreferences:
        locationEngine = new SharedPreferencesEngine(key);
        break;
      case FlutterSaveLocation.documentFile:
        locationEngine = new DocumentFileEngine(key);
        break;
    }
  }

  @override
  load() => locationEngine.load();

  @override
  save(String json) => locationEngine.save(json);
}

/// Storage engine to save to application document directory.
class DocumentFileEngine implements StorageEngine {
  /// File name to save to.
  final String key;

  DocumentFileEngine(this.key);

  @override
  load() async {
    final file = await _getFile();

    if (await file.exists()) {
      // Read to json
      return await file.readAsString();
    }
    return null;
  }

  @override
  save(String json) async {
    final file = await _getFile();
    // Write as json
    await file.writeAsString(json);
  }

  Future<File> _getFile() async {
    // Use the Flutter app documents directory
    final dir = await getApplicationDocumentsDirectory();
    return new File('${dir.path}/persist_$key.json');
  }
}

/// Storage engine to save to NSUserDefaults/SharedPreferences.
class SharedPreferencesEngine implements StorageEngine {
  /// Shared preferences key to save to.
  final String key;

  SharedPreferencesEngine(this.key);

  @override
  load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  save(String json) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json);
  }
}
