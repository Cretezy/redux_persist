library redux_persist_flutter;

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Location to save state when using Flutter
enum FlutterSaveLocation { documentFile, sharedPreference }

/// Storage engine to use with Flutter
/// (proxy of SharedPreferenceEngine and DocumentFileEngine)
class FlutterStorage implements StorageEngine {
  final String key;
  StorageEngine locationEngine;

  FlutterStorage(this.key,
      {FlutterSaveLocation location = FlutterSaveLocation.sharedPreference}) {
    switch (location) {
      case FlutterSaveLocation.sharedPreference:
        locationEngine = new SharedPreferenceEngine(this.key);
        break;
      case FlutterSaveLocation.documentFile:
        locationEngine = new DocumentFileEngine(this.key);
        break;
    }
  }

  @override
  load() => locationEngine.load();

  @override
  save(String json) => locationEngine.save(json);
}

/// Storage engine to save to application document directory
class DocumentFileEngine implements StorageEngine {
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

/// Storage engine to save to NSUserDefaults/SharedPreferences (recommended)
class SharedPreferenceEngine implements StorageEngine {
  final String key;

  SharedPreferenceEngine(this.key);

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

/// PersistorGate waits until state is loaded to render the child [builder]
class PersistorGate extends StatefulWidget {
  final Persistor persistor;
  final WidgetBuilder builder;
  final Widget loading;

  PersistorGate({this.persistor, this.builder, this.loading});

  @override
  State<PersistorGate> createState() => new PersistorGateState();
}

class PersistorGateState extends State<PersistorGate> {
  bool _loaded;

  @override
  initState() {
    super.initState();

    // Pre-loaded state
    _loaded = widget.persistor.loaded;

    // Listen for loads
    widget.persistor.loadStream.first.then(
      (dynamic _) {
        // Set as loaded if not already loaded
        if (!_loaded) {
          setState(() {
            _loaded = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show if loaded, else show [loading] if it exist
    return _loaded
        ? widget.builder(context)
        : (widget.loading ?? new Container(width: 0.0, height: 0.0));
  }
}
