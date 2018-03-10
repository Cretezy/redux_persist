# redux_persist_web [![pub package](https://img.shields.io/pub/v/redux_persist_web.svg)](https://pub.dartlang.org/packages/redux_persist_web)

Web Storage Engine for [`redux_persist`](https://pub.dartlang.org/packages/redux_persist).

Saves to `localStorage`.

## Usage

```dart
var persistor = new Persistor<AppState>(
  // ...
  storage: new WebStorage("my-app"),
);
```

## Features and bugs

Please file feature requests and bugs at the
[issue tracker](https://github.com/Cretezy/redux_persist/issues).
