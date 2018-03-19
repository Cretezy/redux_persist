library redux_persist;

import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';

import 'src/exceptions.dart';
import 'src/transforms.dart';
import 'src/actions.dart';
import 'src/storage.dart';

export 'src/storage.dart' show StorageEngine, FileStorage, MemoryStorage;
export 'src/actions.dart' show LoadAction, LoadedAction, PersistorErrorAction;
export 'src/transforms.dart'
    show Transformer, Transforms, RawTransformer, RawTransforms, Migration;
export 'src/exceptions.dart'
    show
        InvalidVersionException,
        TransformationException,
        StorageException,
        SerializationException;

/// Decoder of state from [json] to <T>
typedef T Decoder<T>(dynamic json);

/// Persistor class that saves/loads to/from disk.
class Persistor<T> {
  final StorageEngine storage;
  final Decoder<T> decoder;
  final int version;
  final Map<int, Migration> migrations;

  final Transforms<T> transforms;
  final RawTransforms rawTransforms;

  final StreamController<T> loadStreamController =
      new StreamController<T>.broadcast();

  bool debug;

  bool _loaded = false;

  Persistor({
    this.storage,
    this.decoder,
    this.version = -1,
    this.migrations,
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
          throw error;
        }
      }
    };
  }

  Future<T> start(Store<T> store) {
    printDebug("Starting");

    // Start stream to listen to next loaded state
    final Future<T> next = loadStream.first;

    // Dispatch load action (to load state)
    store.dispatch(new LoadAction<T>());

    return next;
  }

  /// Load state from disk and dispatch LoadAction to store
  Future<T> load() async {
    printDebug("Starting loading");
    // Load from storage
    String loadedJson;
    try {
      loadedJson = await storage.load();
    } catch (error) {
      throw new StorageException("load: ${error.toString()}");
    }

    T loadedState;

    if (loadedJson != null && loadedJson.isNotEmpty) {
      try {
        // Run all raw load transforms
        rawTransforms?.onLoad?.forEach((transform) {
          loadedJson = transform(loadedJson);
        });
      } catch (error) {
        throw new TransformationException(
            "Load raw transformation: ${error.toString()}");
      }

      dynamic versionedState;
      try {
        versionedState = json.decode(loadedJson);
      } catch (error) {
        throw new SerializationException("Load: ${error.toString()}");
      }

      // TODO: check if savedVersion is really an int

      // Extract versioned variables
      int savedVersion = versionedState["version"];
      dynamic savedState = versionedState["state"];

      if (savedVersion > version) {
        // The version saved is higher than the current version, something is wrong
        throw new InvalidVersionException(
            "Version '$savedVersion' is higher than current version '$version'.");
      }

      final knownVersions = migrations?.keys ?? new List<int>();
      while (savedVersion < version) {
        // Get next possible version (lowest migration that is higher than saved)
        final nextVersions = knownVersions
            .where((version) => version > savedVersion)
            .toList()
              ..sort();
        final nextVersion = nextVersions.first;

        if (nextVersion == null) {
          // No more migrations to be done, can't reach current version
          throw new InvalidVersionException(
              "No more migrations after version '$savedVersion'");
        }

        // Run migration
        savedState = migrations[nextVersion](savedState);
        savedVersion = nextVersion;
      }

      // Decode
      // TODO: add custom serializer
      loadedState = decoder(savedState);

      try {
        // Run all load transforms
        transforms?.onLoad?.forEach((transform) {
          loadedState = transform(loadedState);
        });
      } catch (error) {
        throw new TransformationException(
            "Load transformation: ${error.toString()}");
      }
    }

    printDebug("Done loading");
    // Emit
    _loaded = true;
    loadStreamController.add(loadedState);

    return loadedState;
  }

  /// Save [state] to disk
  Future<void> save(T state) async {
    printDebug("Start saving");

    // Run all save transforms
    try {
      transforms?.onSave?.forEach((transform) {
        state = transform(state);
      });
    } catch (error) {
      throw new TransformationException(
          "Save transformation: ${error.toString()}");
    }

    // Create a versioned state
    final versionedState = {
      "version": version,
      "state": state,
    };

    // Encode to JSON
    // TODO: add custom serializer
    String transformedJson;

    try {
      transformedJson = json.encode(versionedState);
    } catch (error) {
      throw new SerializationException("Save: ${error.toString()}");
    }

    try {
      // Run all raw save transforms
      rawTransforms?.onSave?.forEach((transform) {
        transformedJson = transform(transformedJson);
      });
    } catch (error) {
      throw new TransformationException(
          "Save raw transformation: ${error.toString()}");
    }

    // Save to storage
    try {
      await storage.save(transformedJson);
    } catch (error) {
      throw new StorageException("Save: ${error.toString()}");
    }

    printDebug("Done saving");
  }

  Stream<T> get loadStream => loadStreamController.stream;

  bool get loaded => _loaded;

  void printDebug(Object object) {
    if (debug) print("Persistor debug: $object");
  }
}
