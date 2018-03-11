# redux_persist_flutter [![pub package](https://img.shields.io/pub/v/redux_persist_flutter.svg)](https://pub.dartlang.org/packages/redux_persist_flutter)

Flutter Storage Engine for [`redux_persist`](https://pub.dartlang.org/packages/redux_persist).

Can either save to [`shared_preferences`](https://pub.dartlang.org/packages/shared_preferences)
(default, recommended), or your
[application document directory](https://pub.dartlang.org/packages/path_provider).

Defaults to saving to
[`shared_preferences`](https://pub.dartlang.org/packages/shared_preferences)
(recommended).

To save to a file in your
[application document directory](https://pub.dartlang.org/packages/path_provider),
simply change the `location`:

## Usage

```dart
var persistor = new Persistor<AppState>(
  // ...
  storage: new FlutterStorage("my-app"),
);
```

## Locations

By default, it saves to `FlutterSaveLocation.sharedPreference`
([`shared_preferences`](https://pub.dartlang.org/packages/shared_preferences), recommended).

You can also save to your [application document directory](https://pub.dartlang.org/packages/path_provider)
by using `FlutterSaveLocation.documentFile`:

```dart
new FlutterStorage("my-app", location: FlutterSaveLocation.documentFile)
```

## `PersistorGate`

If you want to wait until rendering you app until the state is loaded,
use the `PersistorGate`:

```dart
@override
Widget build(BuildContext context) {
  return new PersistorGate(
    persistor: persistor,
    builder: (context) => MyApp(),
  );
}
```

If you want to display a loading/slash screen while loading,
pass a widget to render to the `loading` param of `PersistorGate`:

```dart
new PersistorGate(
  persistor: persistor,
  loading: SlashScreen(), // !!!
  builder: (context) => MyApp(),
);
```

## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
