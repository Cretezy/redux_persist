## [0.5.1] - 2018-03-13

* Made `persistor.start` return a Future.
* Add type to `persistor.loadStream`.

## [0.5.0] - 2018-03-12

Breaking changes:
* Change `persistor.load(store)` to `persistor.start(store)` for initial loading.
* Change `LoadAction<T>` to `LoadedAction<T>`.
* Add `LoadAction` (action dispatch to start loading).
* Add `PersistorErrorAction` (action dispatched on save/load error).
* Add `debug` persistor option, doesn't do anything yet.

## [0.4.0] - 2018-03-10

* Decouple Flutter and Web into different packages.

## [0.3.0] - 2018-03-10

* Add state and raw transformers.

## [0.2.0] - 2018-03-10

* Move Flutter-specific code to separate, unexported file.
  It is likely this will become it's own pacakge.
* Add SaveLocation for Flutter storage engine.
* Add SharedPreference sub-engine for Flutter storage engine (make default).
* Fix PersistorGate passing variables to state and initialization.
* Add more docs.

## [0.1.0] - 2018-03-09

* Create generic StorageEngine.
* Create FlutterStorage.

## [0.0.3] - 2018-03-09

* Added documentation.

## [0.0.2] - 2018-03-09

* Added Persistor Gate.

## [0.0.1] - 2018-03-09

* Initial release.
