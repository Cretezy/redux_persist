library redux_persist;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:redux/redux.dart';
import 'package:path_provider/path_provider.dart';

typedef T Decoder<T>(dynamic json);

class LoadAction<T> {
  final T state;

  LoadAction(this.state);
}

class Persistor<T> {
  final String key;
  final Decoder<T> decoder;

  Persistor({this.key, this.decoder});

  Middleware createMiddleware() {
    return (Store store, action, NextDispatcher next) {
      next(action);

      // Save on each action
      _saveToFile(store.state);
    };
  }

  Future<void> load(Store<T> store) async {
    final state = await _loadFromFile();
    store.dispatch(new LoadAction<T>(state));
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
}
