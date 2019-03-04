## `0.8.2` - 2019-03-03

* Use `rethrow` for errors.

## `0.8.1` - 2019-02-18

* Updated `synchronized` package to `2.0.2+1` ([#37](https://github.com/Cretezy/redux_persist/issues/37)).

## `0.8.0` - 2018-11-27

* Release v0.8.0. Last v0.x release line.

## `0.8.0-rc.1` - 2018-11-06

* Fix serializers failing on `null` state.

## `0.8.0-rc.0` - 2018-11-06

* Breaking: Removed migrations
* Breaking: Change saving/loading
* Breaking: Introduced serializers
* Adding throttle
* Added should save (https://github.com/Cretezy/redux_persist/issues/20)
* Added save lock (https://github.com/Cretezy/redux_persist/issues/25)

## `0.7.0` - 2018-08-10

## `0.7.0-rc.2` - 2018-04-09

* Fix middleware typing.

## `0.7.0-rc.1` - 2018-03-31

* Breaking: Dart 2.
* Breaking: Upgraded `redux` to v3.0.0.
* Breaking: Changed loading flow:
  * `persistor.start` has been deprecated (will be removed in next major version).
    Use `persistor.load`
  * Loading dispatched `PersistLoadAction`, then `PersistLoadedAction` once completed.
* Breaking: Changed action names:
  * `LoadAction`: `PersistLoadingAction`
  * `LoadedAction`: `PersistLoadedAction`
  * `PersistorErrorAction`: `PersistErrorAction`
* Added saving actions (`PersistSavingAction` and `PersistSavedAction`)
* Added `MemoryStorage`.
* Added `loadFromStorage` and `saveToStorage` for more manual control.
* Refactor, new tests.

## `0.6.0` - 2018-03-18

* Breaking: Change saved state format.
  This will break your saved state, will only happen once.
* Added migrations and version key.
* Fix JSON deprecation warning.
* Added tests.
* Added exceptions.
* Added `FileStorage`.

## `0.5.2` - 2018-03-14

* Fix library export.

## `0.5.1` - 2018-03-13

* Made `persistor.start` return a `Future`.
* Add type to `persistor.loadStream`.

## `0.5.0` - 2018-03-12

* Breaking: Change `persistor.load(store)` to
  `persistor.start(store)` for initial loading.
* Breaking: Change `LoadAction<T>` to `LoadedAction<T>`.
* Add `LoadAction` (action dispatch to start loading).
* Add `PersistorErrorAction` (action dispatched on save/load error).
* Add `debug` persistor option, doesn't do anything yet.

## `0.4.0` - 2018-03-10

* Breaking: Decouple Flutter and Web into different packages.

## `0.3.0` - 2018-03-10

* Add state and raw transformers.
* Added better error handling (`persistor.errorStream`)

## `0.2.0` - 2018-03-10

* Move Flutter-specific code to separate, unexported file.
  It is likely this will become it's own package.
* Add `SaveLocation` for Flutter storage engine.
* Add `SharedPreference` sub-engine for Flutter storage engine (make default).
* Fix `PersistorGate`passing variables to state and initialization.
* Add more docs.

## `0.1.0` - 2018-03-09

* Create generic `StorageEngine`.
* Create `FlutterStorage`.

## `0.0.3` - 2018-03-09

* Added documentation.

## `0.0.2` - 2018-03-09

* Added `PersistorGate`.

## `0.0.1` - 2018-03-09

* Initial release.
