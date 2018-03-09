library redux_persist_flutter;

import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';

export 'src/flutter.dart' show FlutterStorage, PersistorGate;

// Interface for storage engines
abstract class StorageEngine {
  external Future<void> save(String json);

  external Future<String> load();
}

/// Decoder of state from [json] to <T>
typedef T Decoder<T>(dynamic json);

/// Action being dispatched when loading state from disk.
class LoadAction<T> {
  final T state;

  LoadAction(this.state);
}

// Persistor class that saves/loads to/from disk.
class Persistor<T> {
  final StorageEngine storage;
  final Decoder<T> decoder;

  final StreamController loadStreamController =
      new StreamController.broadcast();
  var loaded = false;

  Persistor({this.storage, this.decoder});

  /// Middleware used for Redux which saves on each action.
  Middleware createMiddleware() {
    return (Store store, action, NextDispatcher next) {
      next(action);

      // Save on each action
      storage.save(JSON.encode(store.state));
    };
  }

  /// Load state from disk and dispatch LoadAction to [store]
  Future<void> load(Store<T> store) async {
    final json = await storage.load();
    final state = decoder(json);

    // Dispatch LoadAction to store
    store.dispatch(new LoadAction<T>(state));

    // Emit
    loadStreamController.add(true);
    loaded = true;
  }

  Stream get loadStream => loadStreamController.stream;
}
