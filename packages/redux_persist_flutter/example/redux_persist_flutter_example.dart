import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

void main() {
  runApp(new MyApp());
}

// Redux
class AppState {
  final int counter;

  AppState({this.counter = 0});

  AppState copyWith({int counter}) {
    return new AppState(counter: counter ?? this.counter);
  }

  static AppState fromJson(dynamic json) {
    return new AppState(counter: json["counter"]);
  }

  Map toJson() => {'counter': counter};
}

class IncrementCounterAction {}

AppState reducer(state, action) {
  // Load to state
  if (action is LoadAction<AppState>) {
    return action.state ?? state;
  }

  switch (action.runtimeType) {
    case IncrementCounterAction:
      return state.copyWith(counter: state.counter + 1);
    default:
      // No change
      return state;
  }
}

// App
class MyApp extends StatelessWidget {
  var persistor;
  var store;

  MyApp() {
    // Create Persistor
    persistor = new Persistor<AppState>(
      storage: new FlutterStorage("my-app"),
      decoder: AppState.fromJson,
    );

    store = new Store<AppState>(
      reducer,
      initialState: new AppState(),
      middleware: [persistor.createMiddleware()],
    );

    // Load state and dispatch LoadAction
    persistor.load(store);
  }

  @override
  Widget build(BuildContext context) {
    // PersistorGate waits for state to be loaded before rendering
    return new PersistorGate(
      persistor: persistor,
      child: (context) => new StoreProvider(
            store: store,
            child: new MaterialApp(
                title: 'Redux Persist Demo', home: new MyHomePage()),
          ),
    );
  }
}

// Counter example
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Redux Persist demo"),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new StoreConnector<AppState, String>(
              converter: (store) => store.state.counter.toString(),
              builder: (context, count) => new Text(
                    '$count',
                    style: Theme.of(context).textTheme.display1,
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: new StoreConnector<AppState, VoidCallback>(
        converter: (store) {
          // Return a `VoidCallback`, which is a fancy name for a function
          // with no parameters. It only dispatches an Increment action.
          return () => store.dispatch(new IncrementCounterAction());
        },
        builder: (context, callback) => new FloatingActionButton(
              onPressed: callback,
              tooltip: 'Increment',
              child: new Icon(Icons.add),
            ),
      ),
    );
  }
}
