library redux_persist;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';
import 'package:path_provider/path_provider.dart';

/// Decoder of state from [json] to <T>
typedef T Decoder<T>(dynamic json);

/// Action being dispatched when loading state from disk.
class LoadAction<T> {
  final T state;

  LoadAction(this.state);
}

// Persistor class that saves/loads to/from disk.
class Persistor<T> {
  final String key;
  final Decoder<T> decoder;
  StreamController loadStreamController = new StreamController.broadcast();
  var loaded = false;

  Persistor({this.key, this.decoder});

  /// Middleware used for Redux which saves on each action.
  Middleware createMiddleware() {
    return (Store store, action, NextDispatcher next) {
      next(action);

      // Save on each action
      _saveToFile(store.state);
    };
  }

  /// Load state from disk and dispatch LoadAction to [store]
  Future<void> load(Store<T> store) async {
    final state = await _loadFromFile();
    store.dispatch(new LoadAction<T>(state));
    loadStreamController.add(true);
    loaded = true;
  }

  Future<void> _saveToFile(T state) async {
    final file = await _getFile();
    // Write as json
    await file.writeAsString(JSON.encode(state));
  }

  Future<T> _loadFromFile() async {
    final file = await _getFile();

    if (await file.exists()) {
      // Read to json
      final string = await file.readAsString();
      final json = JSON.decode(string);

      // Decode from json to T
      return decoder(json);
    }

    return null;
  }

  Future<File> _getFile() async {
    // Use the Flutter app documents directory
    final dir = await getApplicationDocumentsDirectory();
    return new File('${dir.path}/persist_$key.json');
  }

  Stream get loadStream => loadStreamController.stream;
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

  void load() {}

  PersistorGateState({this.persistor, this.child, this.loading}) {
    loaded = persistor.loaded;
    persistor.loadStream.listen((_) => setState(() {
          loaded = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return loaded ? child : (loading ?? new Container(width: 0.0, height: 0.0));
  }
}
