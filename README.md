# redux_persist

Persist Redux state across app restarts in Flutter.

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
The `fromJson` is required, but can be renamed)

### Persistor

Next, create your persistor, storage engine, and store, then load the last state in.
This will usually be in your `main` or in your root widget:

```dart
persistor = new Persistor<AppState>(
  storage: new FlutterStorage("my-app"),
  decoder: AppState.fromJson,
);

store = new Store<AppState>(
  reducer,
  initialState: new AppState(),
  middleware: [persistor.createMiddleware()],
);

persistor.load(store);
```

(the `key` param  is used as a key of the save file name.
The `decoder` param takes in a `dynamic` type and outputs
an instance of your state class, see the above example)

### Load

In your reducer, you must add a check for the `LoadAction` action, like so:

```dart
class IncrementCounterAction {}

AppState reducer(state, action) {
  // !!!
  if (action is LoadAction<AppState>) {
    return action.state;
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

## Persistor Gate

If you want to wait until rendering you app until the state is loaded, use the `PersistorGate`:

```dart
@override
Widget build(BuildContext context) {
  return new PersistorGate(
    persistor: persistor,
    child: MyApp()
  );
}
```

If you want to display a loading screen (or slash screen), pass the Widget to render to the `loading` param of PersistorGate.

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/Cretezy/redux_persist/issues).
