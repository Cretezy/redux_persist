# redux_persist_web [![pub package](https://img.shields.io/pub/v/redux_persist_web.svg)](https://pub.dartlang.org/packages/redux_persist_web)

Web Storage Engine for [`redux_persist`](https://pub.dartlang.org/packages/redux_persist).

Saves to `localStorage`.

## Usage

```dart
final persistor = Persistor<AppState>(
  // ...
  storage: WebStorage(),
);
```

## Key

You can pass a key argument to `WebStorage` to set the key for `localStorage`.


## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
