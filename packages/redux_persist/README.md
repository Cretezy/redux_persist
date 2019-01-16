# redux_persist [![pub package](https://img.shields.io/pub/v/redux_persist.svg)](https://pub.dartlang.org/packages/redux_persist)

Persist [Redux](https://pub.dartlang.org/packages/redux) state across app restarts in Flutter, Web, or custom storage engines.

Features:

* Save and load from multiple engine (Flutter, Web, File, custom)
* Fully type safe
* Transform state and raw on load/save
* Custom serializers
* Easy to use, integrate into your codebase in a few minutes!

Storage Engines:

* [Flutter](https://pub.dartlang.org/packages/redux_persist_flutter)
* [Web](https://pub.dartlang.org/packages/redux_persist_web)
* File and custom (see below)

## Usage

See [Flutter example](https://github.com/Cretezy/redux_persist/tree/master/packages/redux_persist_flutter/example) for a full overview.

The library creates a middleware that saves on every action.

### State Setup

We will be using the `JsonSerializer`, you will need to use a state class, with a required `toJson` method, as such:

```dart
class AppState {
  final int counter;

  AppState({this.counter = 0});

  AppState copyWith({int counter}) =>
      AppState(counter: counter ?? this.counter);

  // !!!
  static AppState fromJson(dynamic json) => AppState(counter: json["counter"]);

  // !!!
  dynamic toJson() => {'counter': counter};
}
```

(the `copyWith` method is optional, but a great helper.
The `fromJson` is required as decoder, but can be renamed)

### Persistor

Next, create your persistor, storage engine,
and store, then load the last state in.
This will usually be in your `main` or in your root widget:

```dart
void main() async {
  // Create Persistor
  final persistor = Persistor<AppState>(
    storage: FileStorage(File("state.json")), // Or use other engines
    serializer: JsonSerializer<AppState>(AppState.fromJson), // Or use other serializers
  );
  
  // Load initial state
  final initialState = await persistor.load();
  
  // Create Store with Persistor middleware
  final store = Store<AppState>(
    reducer,
    initialState: initialState ?? AppState(),
    middleware: [persistor.createMiddleware()],
  );
  
  // ..
}
```

(`JsonSerializer` takes a single param which turns the JSON into your `AppState`. Your state will automatically be saved using the middleware)

## Storage Engines

You can use different storage engines for different application types:

* [Flutter](https://pub.dartlang.org/packages/redux_persist_flutter)
* [Web](https://pub.dartlang.org/packages/redux_persist_web)
* `FileStorage`:

  ```dart
  final persistor = Persistor<AppState>(
    // ...
    storage: FileStorage(File("path/to/state")),
  );
  ```

* Build your own custom storage engine:

  To create a custom engine, you will need to implement the following [interface](https://github.com/Cretezy/redux_persist/blob/master/packages/redux_persist/lib/src/storage.dart#L6)
  to save/load a string to disk:

  ```dart
  abstract class StorageEngine {
    external Future<void> save(Uint8List data);

    external Future<Uint8List> load();
  }
  ```
  
## Serializers

You can use one of the [built in serializers](./lib/src/serialization.dart) such as:

* `JsonSerializer`
* `StringSerializer`
* `RawSerializer`

* Build your own serializer:

  To create a custom engine, you will need to implement the following [interface](https://github.com/Cretezy/redux_persist/blob/master/packages/redux_persist/lib/src/serialization.dart#L5)
  to encode/decode state to/from `Uint8List`:

  ```dart
  abstract class StateSerializer<T> {
    external Uint8List encode(T state);
    external T decode(Uint8List data);
  }
  ```
  
  Example:
  
  ```dart
  class IntSerializer implements StateSerializer<int> {
    /// Takes [data] and converts it to a [int]
    @override
    int decode(Uint8List data) {
      return ByteData.view(data.buffer).getInt64(0);
    }
      
    /// Takes [state] and converts it to a [Uint8List]
    @override
    Uint8List encode(int state) {
      final data = Uint8List(8);
      ByteData.view(data.buffer).setInt64(0, state);
      return data;
    }
  }
  ```

## Whitelist/Blacklist

To only save parts of your state,
simply omit the fields that you wish to not save
from your serializer.

If using the `JsonSerializer`, you can omit them from you `toJson` and decoder.

For instance, if we have a state with `counter` and `name`,
but we don't want `counter` to be saved, you would do:

```dart
class AppState {
  final int counter;
  final String name;

  AppState({this.counter = 0, this.name});

  // ...

  static AppState fromJson(dynamic json) =>
      AppState(name: json["name"]); // Don't load counter, will use default of 0


  Map toJson() => {'name': name}; // Don't save counter
}
```

## Transforms

Transformations are a way to transform ("edit") your state when loading/saving. They are 2 types:

All transformers are ran in order, from first to last.

Make sure all transformation are pure. Do not mutate the original state passed.

### State

State transformations transform your _state_
before it's written to disk (on save) or loaded from disk (on load).

```dart
final persistor = Persistor<AppState>(
  // ...
  transforms: Transforms(
    onSave: [
      // Example: set counter to 3 when writing to disk
      (state) => state.copyWith(counter: 3),
    ],
    onLoad: [
      // Example: set counter to 0 when loading from disk
      (state) => state.copyWith(counter: 0),
    ],
  ),
);
```

### Raw

Raw transformation are applied to the raw byte (`Uint8List`)
before it's saved/loaded.

```dart
final persistor = Persistor<AppState>(
  // ...
  rawTransforms: RawTransforms(
    onSave: [
      // Example: encrypt raw data
      (data) => encrypt(data),
    ],
    onLoad: [
      // Example: decrypt raw data
      (data) => decrypt(data),
    ],
  )
);
```

## Debug

`Persistor` has a `debug` option, which will eventually log more debug information.

Use it like so:

```dart
final persistor = Persistor<AppState>(
  // ...
  debug: true
);
```

## Throttle duration

`Persistor` has a `throttleDuration` option, which will throttle saving to disk to prevent excessive
writing. You should keep this at a low value to prevent data loss (few seconds is recommended).

Use it like so:

```dart
final persistor = Persistor<AppState>(
  // ...
  throttleDuration: Duration(seconds: 2),
);
```


## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
