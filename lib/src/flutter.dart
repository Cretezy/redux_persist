library redux_persist;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux_persist/redux_persist.dart';

class FlutterStorage implements StorageEngine {
  final String key;

  FlutterStorage(this.key);

  @override
  load() async {
    final file = await _getFile();

    if (await file.exists()) {
      // Read to json
      final string = await file.readAsString();
      return JSON.decode(string);
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

// PersistorGate waits until state is loaded to render the child
class PersistorGate extends StatefulWidget {
  final persistor;
  final child;
  final loading;

  PersistorGate({this.persistor, this.child, this.loading});

  @override
  State<PersistorGate> createState() => new PersistorGateState(
      persistor: persistor, child: child, loading: loading);
}

class PersistorGateState extends State<PersistorGate> {
  final persistor;
  final child;
  final loading;

  var loaded;

  PersistorGateState({this.persistor, this.child, this.loading}) {
    loaded = persistor.loaded;
    persistor.loadStream.listen(
      (_) => setState(() {
            loaded = true;
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show if loaded, else show [loading] if it exist
    return loaded ? child : (loading ?? new Container(width: 0.0, height: 0.0));
  }
}
