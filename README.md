# redux_persist [![pub package](https://img.shields.io/pub/v/redux_persist.svg)](https://pub.dartlang.org/packages/redux_persist)

Persist Redux state across app restarts in Flutter or custom storage engines.

[Article](https://medium.com/@cretezy/persist-redux-in-flutter-a2082bbb9aa0).

## Usage

See [example](example) for a full overview.

The library creates a middleware that saves on every action.
It also loads on initial load and sets a `LoadAction` to your store.

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
persistor = new Persistor<AppState>(
  storage: new FlutterStorage("my-app"), // Or use other engines
  decoder: AppState.fromJson,
);

// Create Store with Persistor middleware
store = new Store<AppState>(
  reducer,
  initialState: new AppState(),
  middleware: [persistor.createMiddleware()],
);

// Load state to store
persistor.load(store);
```

(the `key` param is used as a key of the save file name.
The `decoder` param takes in a `dynamic` type and outputs
an instance of your state class, see the above example)

### Load

In your reducer, you must add a check for the
`LoadAction` action (with the generic type), like so:

```dart
class IncrementCounterAction {}

AppState reducer(state, action) {
  // !!!
  if (action is LoadAction<AppState>) {
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

## `PersistorGate` (Flutter only)

If you want to wait until rendering you app until the state is loaded,
use the `PersistorGate`:

```dart
@override
Widget build(BuildContext context) {
  return new PersistorGate(
    persistor: persistor,
    child: MyApp(),
  );
}
```

If you want to display a loading/slash screen while loading,
pass a widget to render to the `loading` param of `PersistorGate`:

```dart
new PersistorGate(
  persistor: persistor,
  loading: SlashScreen(), // !!!
  child: MyApp(),
);
```

## Storage Engines

### `FlutterStorage`

Storage engine to use with Flutter. Defaults to saving to
[`shared_preferences`](https://pub.dartlang.org/packages/shared_preferences)
(recommended).

To save to a file in your
[application document directory](https://pub.dartlang.org/packages/path_provider),
simply change the `location`:

```dart
new FlutterStorage("my-app", location: FlutterSaveLocation.documentFile)
```

> You can also directly use `SharedPreferenceEngine` and `DocumentFileEngine`,
> but using the `FlutterStorage` is recommended for simplicity.

### Custom Storage Engines

If you are not using `redux_persist` with Flutter,
you can pass a custom `StorageEngine` to the `storage` param of the Persistor.

You will need to implement the following interface to save/load a JSON string to disk:

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
    return new AppState(name: json["name"]); // No `counter`
  }

  Map toJson() => {'name': name}; // No counter
}
```

## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
