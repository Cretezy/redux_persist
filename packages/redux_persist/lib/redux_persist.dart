library redux_persist;

import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';

import 'src/actions.dart';
import 'src/exceptions.dart';
import 'src/storage.dart';
import 'src/transforms.dart';

export 'src/actions.dart'
    show
        PersistLoadingAction,
        PersistLoadedAction,
        PersistSavingAction,
        PersistSavedAction,
        PersistErrorAction,
        PersistAction;
export 'src/exceptions.dart'
    show
        InvalidVersionException,
        TransformationException,
        StorageException,
        SerializationException;
export 'src/storage.dart' show StorageEngine, FileStorage, MemoryStorage;
export 'src/transforms.dart'
    show Transformer, Transforms, RawTransformer, RawTransforms, Migration;

/// Decoder of state from [json] to <T>
typedef T Decoder<T>(dynamic json);

/// Persistor class that saves/loads to/from disk.
class Persistor<T> {
  /// Storage engine to save/load from/to.
  final StorageEngine storage;

  /// Decoder to map a Map (from JSON) to [T]
  final Decoder<T> decoder;

  /// State version.
  final int version;

  /// State migrations between versions.
  final Map<int, Migration> migrations;

  /// Transformations on state to be applied on save/load.
  final Transforms<T> transforms;

  /// Transforamtions on raw state (JSON) to be applied on save/load.
  final RawTransforms rawTransforms;

  final StreamController<T> _loadStreamController =
      new StreamController<T>.broadcast();

  final StreamController<dynamic> _errorStreamController =
      new StreamController<dynamic>.broadcast();

  /// Debug mode (prints debug information).
  bool debug;

  bool _loaded = false;

  /// Create a persistor.
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
  Middleware<T> createMiddleware() =>
      (Store<T> store, dynamic action, NextDispatcher next) {
        next(action);

        if (action is! PersistAction) {
          try {
            // Save
            save(store);
          } catch (_) {}
        }
      };

  /// Use `load`.
  @deprecated
  Future<T> start(Store<T> store) => load(store);

  /// Load state.
  Future<T> load(Store<T> store) async {
    try {
      _printDebug('Starting loading');

      store.dispatch(PersistLoadingAction());

      T state = await loadFromStorage();

      _loaded = true;
      _loadStreamController.add(state);

      // Dispatch loaded action
      store.dispatch(PersistLoadedAction(state));

      _printDebug('Done loading');

      return state;
    } catch (error) {
      _printDebug('Error in load: ${error.toString()}');

      _errorStreamController.add(error);
      store.dispatch(PersistErrorAction(error));

      throw error;
    }
  }

  /// Load state from storage. Use `load`.
  Future<T> loadFromStorage() async {
    // Load from storage
    String loadedJson;
    try {
      loadedJson = await storage.load();
    } catch (error) {
      throw new StorageException('load: ${error.toString()}');
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
            'Load raw transformation: ${error.toString()}');
      }

      dynamic versionedState;
      try {
        versionedState = json.decode(loadedJson);
      } catch (error) {
        throw new SerializationException('Load: ${error.toString()}');
      }

      // TODO: check if savedVersion is really an int

      // Extract versioned variables
      int savedVersion = versionedState['version'];
      dynamic savedState = versionedState['state'];

      if (savedVersion > version) {
        // The version saved is higher than the current version, something is wrong
        throw new InvalidVersionException(
            'Version "$savedVersion" is higher than current version "$version".');
      }

      final knownVersions = migrations?.keys ?? <int>[].toList();
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
              'No more migrations after version "$savedVersion"');
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
            'Load transformation: ${error.toString()}');
      }
    }

    return loadedState;
  }

  /// Save state.
  Future<void> save(Store<T> store) async {
    try {
      _printDebug('Start saving');

      // Dispatch saving action
      store.dispatch(PersistSavingAction());

      await saveToStorage(store.state);

      // Dispatch saved action
      store.dispatch(PersistSavedAction());

      _printDebug('Done saving');
    } catch (error) {
      _printDebug('Error in save: ${error.toString()}');

      _errorStreamController.add(error);
      store.dispatch(PersistErrorAction(error));

      throw error;
    }
  }

  /// Save state to storage. Use `save`.
  Future<void> saveToStorage(T state) async {
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
      'version': version,
      'state': state,
    };

    String transformedJson;

    try {
      // Encode to JSON
      // TODO: add custom serializer
      transformedJson = json.encode(versionedState);
    } catch (error) {
      throw new SerializationException('Save: ${error.toString()}');
    }

    try {
      // Run all raw save transforms
      rawTransforms?.onSave?.forEach((transform) {
        transformedJson = transform(transformedJson);
      });
    } catch (error) {
      throw new TransformationException(
          'Save raw transformation: ${error.toString()}');
    }

    // Save to storage
    try {
      await storage.save(transformedJson);
    } catch (error) {
      throw new StorageException('Save: ${error.toString()}');
    }
  }

  /// Stream of states after a load.
  Stream<T> get loadStream => _loadStreamController.stream;

  /// Stream of errors on save/load.
  Stream<dynamic> get errorStream => _errorStreamController.stream;

  /// If state has loaded.
  bool get loaded => _loaded;

  void _printDebug(Object object) {
    if (debug) {
      print('Persistor debug: $object');
    }
  }
}
