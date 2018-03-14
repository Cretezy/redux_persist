# redux_persist [![pub package](https://img.shields.io/pub/v/redux_persist.svg)](https://pub.dartlang.org/packages/redux_persist)

Persist [Redux](https://pub.dartlang.org/packages/redux) state across app restarts in Flutter, Web, or custom storage engines.

Features:

* Save and load from multiple engine (Flutter, Web, custom)
* Fully type safe
* Transform state and raw on load/save
* Flutter integration (`PersistorGate`)
* Easy to use, integrate into your codebase in a few minutes!

Storage Engines:

* [Flutter](https://pub.dartlang.org/packages/redux_persist_flutter)
* [Web](https://pub.dartlang.org/packages/redux_persist_web)
* Custom (see below)

## Usage

See [Flutter example](https://github.com/Cretezy/redux_persist/tree/master/packages/redux_persist_flutter/example) for a full overview.

The library creates a middleware that saves on every action.
It also loads on initial load and sets a `LoadedAction` to your store.

### State Setup

You will need to use a state class, with a required `toJson` method, as such:

```dart
class AppState {
  final int counter;

  AppState({this.counter = 0});

  AppState copyWith({int counter}) {
    return new AppState(counter: counter ?? this.counter);
  }

  // !!!
  static AppState fromJson(dynamic json) {
    return new AppState(counter: json["counter"]);
  }

  // !!!
  Map toJson() => {
    'counter': counter
  };
}
```

(the `copyWith` method is optional, but a great helper.
The `fromJson` is required as decoder, but can be renamed)

### Persistor

Next, create your persistor, storage engine,
and store, then load the last state in.
This will usually be in your `main` or in your root widget:

```dart
// Create Persistor
var persistor = new Persistor<AppState>(
  storage: new FlutterStorage("my-app"), // Or use other engines
  decoder: AppState.fromJson,
);

// Create Store with Persistor middleware
var store = new Store<AppState>(
  reducer,
  initialState: new AppState(),
  middleware: [persistor.createMiddleware()],
);

// Load state to store
persistor.start(store);
```

(the `key` param is used as a key of the save file name.
The `decoder` param takes in a `dynamic` type and outputs
an instance of your state class, see the above example)

### Load

In your reducer, you must add a check for the
`LoadedAction` action (with the generic type), like so:

```dart
class IncrementCounterAction {}

AppState reducer(state, action) {
  // !!!
  if (action is LoadedAction<AppState>) {
    return action.state ?? state; // Use existing state if null
  }
  // !!!

  switch (action.runtimeType) {
    case IncrementCounterAction:
      return state.copyWith(counter: state.counter + 1);
    default:
      // No change
      return state;
  }
}
```

### Optional Actions

You can also use the `LoadAction` or `PersistorErrorAction` to follow the lifecycle of the persistor.

* `LoadAction` is dispatched when the store is being loaded
* `PersistorErrorAction` is dispatched when an error occurs on loading/saving

## Storage Engines

You can use the [Flutter](https://pub.dartlang.org/packages/redux_persist_flutter)
or [Web](https://pub.dartlang.org/packages/redux_persist_web) engines,
or build your own custom storage engine.

To create a custom engine, you will need to implement the following interface
to save/load a JSON string to disk:

```dart
abstract class StorageEngine {
  external Future<void> save(String json);

  external Future<String> load();
}
```

## Whitelist/Blacklist

To only save parts of your state,
simply omit the fields that you wish to not save
from your `toJson` and decoder (usually `fromJson`) methods.

For instance, if we have a state with `counter` and `name`,
but we don't want `counter` to be saved, you would do:

```dart
class AppState {
  final int counter;
  final String name;

  AppState({this.counter = 0, this.name});

  // ...

  static AppState fromJson(dynamic json) {
    return new AppState(name: json["name"]); // Don't load counter, will use default of 0
  }

  Map toJson() => {'name': name}; // Don't save counter
}
```

## Transforms

All transformers are ran in order, from first to last.

Make sure all transformation are pure. Do not modify the original state passed.

### State

State transformations transform your *state*
before it's written to disk (on save) or loaded from disk (on load).

```dart
persistor = new Persistor<AppState>(
  // ...
  transforms: new Transforms(
    onSave: [
      // Set counter to 3 when writing to disk
      (state) => state.copyWith(counter: 3),
    ],
    onLoad: [
      // Set counter to 0 when loading from disk
      (state) => state.copyWith(counter: 0),
    ],
  ),
);
```

### Raw

Raw transformation are applied to the raw text (JSON)
before it's written to disk (on save) or loaded from disk (on load).

```dart
persistor = new Persistor<AppState>(
  // ...
  rawTransforms: new RawTransforms(
    onSave: [
      // Encrypt raw json
      (json) => encrypt(json),
    ],
    onLoad: [
      // Decrypt raw json
      (json) => decrypt(json),
    ],
  )
);
```

## Debug

`Persistor` has a `debug` option, which will eventually log debug information.

Use it like so:

```dart
persistor = new Persistor<AppState>(
  // ...
  debug: true
);
```

## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
