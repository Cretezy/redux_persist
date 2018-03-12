library redux_persist_flutter;

import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';

// Interface for storage engines
abstract class StorageEngine {
  external Future<void> save(String json);

  external Future<String> load();
}

/// Decoder of state from [json] to <T>
typedef T Decoder<T>(dynamic json);

/// Action being dispatched when done loading the state from disk.
class LoadedAction<T> {
  final T state;

  LoadedAction(this.state);
}

/// Action being dispatched to load the state from disk.
class LoadAction<T> {}

/// Action being dispatched when error loading/saving to disk
class PersistorErrorAction {}

/// Persistor class that saves/loads to/from disk.
class Persistor<T> {
  final StorageEngine storage;
  final Decoder<T> decoder;

  final Transforms<T> transforms;
  final RawTransforms rawTransforms;

  final StreamController<void> loadStreamController =
      new StreamController.broadcast();

  final bool debug;

  var loaded = false;

  Persistor({
    this.storage,
    this.decoder,
    this.transforms,
    this.rawTransforms,
    this.debug = false,
  });

  /// Middleware used for Redux which saves on each action.
  Middleware createMiddleware() {
    return (Store store, dynamic action, NextDispatcher next) {
      next(action);

      // Don't run load/save on error
      if (action is! PersistorErrorAction) {
        try {
          if (action is LoadAction<T>) {
            // Load and dispatch to state
            load().then((state) => store.dispatch(new LoadedAction<T>(state)));
          } else {
            // Save
            save(store.state as T);
          }
        } catch (error) {
          store.dispatch(new PersistorErrorAction());
        }
      }
    };
  }

  void start(Store<T> store) {
    store.dispatch(new LoadAction<T>());
  }

  /// Load state from disk and dispatch LoadAction to [store]
  Future<T> load() async {
    var json = await storage.load();
    T state;

    if (json != null) {
      rawTransforms?.onLoad?.forEach((transform) {
        // Run all raw load transforms
        json = transform(json);
      });

      state = decoder(JSON.decode(json));

      transforms?.onLoad?.forEach((transform) {
        // Run all load transforms
        state = transform(state);
      });
    }

    // Emit
    loadStreamController.add(true);
    loaded = true;

    return state;
  }

  /// Save [state] to disk
  Future<void> save(T state) async {
    // Avoid replacing initial state
    var transformedState = state;
    transforms?.onSave?.forEach((transform) {
      // Run all save transforms
      transformedState = transform(transformedState);
    });

    var json = JSON.encode(transformedState);

    rawTransforms?.onSave?.forEach((transform) {
      // Run all raw save transforms
      json = transform(json);
    });

    await storage.save(json);
  }

  Stream get loadStream => loadStreamController.stream;
}

/// Transforms state (without mutating)
typedef T Transformer<T>(final T state);

/// Holds onSave and onLoad transformations.
class Transforms<T> {
  final List<Transformer<T>> onSave;
  final List<Transformer<T>> onLoad;

  Transforms({this.onSave, this.onLoad});
}

/// Transforms JSON state
typedef String RawTransformer(final String json);

/// Holds onSave and onLoad raw transformations.
class RawTransforms {
  final List<RawTransformer> onSave;
  final List<RawTransformer> onLoad;

  RawTransforms({this.onSave, this.onLoad});
}
