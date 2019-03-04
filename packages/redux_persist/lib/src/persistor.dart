import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/src/exceptions.dart';
import 'package:redux_persist/src/serialization.dart';
import 'package:redux_persist/src/storage.dart';
import 'package:redux_persist/src/transforms.dart';
import 'package:synchronized/synchronized.dart';

/// Persistor class that saves/loads to/from disk.
class Persistor<T> {
  /// Storage engine to save/load from/to.
  final StorageEngine storage;

  /// Transformations on state to be applied on save/load.
  final Transforms<T> transforms;

  /// Transformations on raw data to be applied on save/load.
  final RawTransforms rawTransforms;

  /// State serialized used to serialize the state to/from bytes.
  final StateSerializer<T> serializer;

  /// Debug mode (prints debug information).
  bool debug;

  /// Duration for which to throttle saving. Disable by setting to null.
  /// It is recommended to set a duration of a few (2-5) seconds to reduce
  /// storage calls, while preventing data loss.
  /// A duration of zero (default) will try to save on next available cycle
  Duration throttleDuration;

  /// Synchronization lock for saving
  final _saveLock = Lock();

  /// Function that if not null, returns if an action should trigger a save.
  final bool Function(Store<T> store, dynamic action) shouldSave;

  Persistor({
    @required this.storage,
    @required this.serializer,
    this.transforms,
    this.rawTransforms,
    this.debug = false,
    this.throttleDuration = Duration.zero,
    this.shouldSave,
  });

  /// Middleware used for Redux which saves on each action.
  Middleware<T> createMiddleware() {
    Timer _saveTimer;

    return (Store<T> store, dynamic action, NextDispatcher next) {
      next(action);

      if (shouldSave != null && shouldSave(store, action) != true) {
        return;
      }

      // Save
      try {
        if (throttleDuration != null) {
          // Only create a new timer if the last one hasn't been run.
          if (_saveTimer?.isActive != true) {
            _saveTimer = Timer(throttleDuration, () => save(store.state));
          }
        } else {
          save(store.state);
        }
      } catch (_) {}
    };
  }

  /// Load state from storage
  Future<T> load() async {
    try {
      _printDebug('Starting load...');

      _printDebug('Loading from storage');

      // Load from storage
      Uint8List data;
      try {
        data = await storage.load();
      } catch (error) {
        throw StorageException('On load: ${error.toString()}');
      }

      _printDebug('Running load raw transformations');

      try {
        // Run all raw load transforms
        rawTransforms?.onLoad?.forEach((transform) {
          data = transform(data);
        });
      } catch (error) {
        throw TransformationException(
          'On load raw transformation: ${error.toString()}',
        );
      }

      _printDebug('Deserializing');

      T state;
      try {
        state = serializer.decode(data);
      } catch (error) {
        throw SerializationException('On load: ${error.toString()}');
      }

      _printDebug('Running load transformations');

      try {
        // Run all load transforms
        transforms?.onLoad?.forEach((transform) {
          state = transform(state);
        });
      } catch (error) {
        throw TransformationException(
          'On load transformation: ${error.toString()}',
        );
      }

      _printDebug('Done loading!');

      return state;
    } catch (error) {
      _printDebug('Error while loading: ${error.toString()}');
      rethrow;
    }
  }

  /// Save state to storage.
  Future<void> save(T state) async {
    try {
      _printDebug('Starting save...');

      _printDebug('Running save transformations');

      // Run all save transforms
      try {
        transforms?.onSave?.forEach((transform) {
          state = transform(state);
        });
      } catch (error) {
        throw TransformationException(
          "On save transformation: ${error.toString()}",
        );
      }

      _printDebug('Serializing');

      var data = serializer.encode(state);

      _printDebug('Running save raw transformations');

      try {
        // Run all raw save transforms
        rawTransforms?.onSave?.forEach((transform) {
          data = transform(data);
        });
      } catch (error) {
        throw TransformationException(
            'On save raw transformation: ${error.toString()}');
      }

      _printDebug('Saving to storage');

      // Save to storage
      try {
        // Use lock to prevent writing twice at the same time
        await _saveLock.synchronized(() async => await storage.save(data));
      } catch (error) {
        throw StorageException('On save: ${error.toString()}');
      }

      _printDebug('Done saving!');
    } catch (error) {
      _printDebug('Error while saving: ${error.toString()}');
      rethrow;
    }
  }

  void _printDebug(Object object) {
    if (debug) {
      print('Persistor debug: $object');
    }
  }
}
