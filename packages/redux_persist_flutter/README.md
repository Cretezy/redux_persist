# redux_persist_flutter [![pub package](https://img.shields.io/pub/v/redux_persist_flutter.svg)](https://pub.dartlang.org/packages/redux_persist_flutter)

Flutter Storage Engine for [`redux_persist`](https://pub.dartlang.org/packages/redux_persist).

Can either save to [`shared_preferences`](https://pub.dartlang.org/packages/shared_preferences)
(default, recommended), or your
[application document directory](https://pub.dartlang.org/packages/path_provider).

## Usage

```dart
final persistor = Persistor<State>(
  // ...
  storage: FlutterStorage("my-app"),
);
```

## `PersistorGate`

If you want to wait until rendering you app until the state is loaded,
use the `PersistorGate`:

```dart
@override
Widget build(BuildContext context) {
  return PersistorGate(
    persistor: persistor,
    builder: (context) => MyApp(),
  );
}
```

If you want to display a loading/slash screen while loading,
pass a widget to render to the `loading` param of `PersistorGate`:

```dart
PersistorGate(
  persistor: persistor,
  loading: SlashScreen(), // !!!
  builder: (context) => MyApp(),
);
```

## Locations

By default, it saves to `FlutterSaveLocation.documentFile`
([application document directory](https://pub.dartlang.org/packages/path_provider), recommended).

You can also save to your [shared preferences](https://pub.dartlang.org/packages/shared_preferences) by using `FlutterSaveLocation.sharedPreferences`:

```dart
// Use shared preferences
FlutterStorage("my-app", location: FlutterSaveLocation.sharedPreferences)
```

## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
