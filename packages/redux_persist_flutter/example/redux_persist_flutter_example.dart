import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

void main() => runApp(App());

// Redux
class AppState {
  final int counter;

  AppState({this.counter = 0});

  AppState copyWith({int counter}) =>
      AppState(counter: counter ?? this.counter);

  static AppState fromJson(dynamic json) =>
      AppState(counter: json["counter"] as int);

  dynamic toJson() => {'counter': counter};
}

class IncrementCounterAction {}

AppState reducer(AppState state, Object action) {
  if (action is PersistLoadedAction<AppState>) {
    // Load to state
    return action.state ?? state;
  } else if (action is IncrementCounterAction) {
    // Increment
    return state.copyWith(counter: state.counter + 1);
  }

  return state;
}

// App
class App extends StatelessWidget {
  Persistor<AppState> persistor;
  Store<AppState> store;

  App() {
    // Create Persistor
    persistor = Persistor<AppState>(
      storage: FlutterStorage("my-app"),
      decoder: AppState.fromJson,
    );

    store = Store<AppState>(
      reducer,
      initialState: AppState(),
      middleware: [persistor.createMiddleware()],
    );

    // Load initial state
    persistor.load(store);
  }

  @override
  Widget build(BuildContext context) {
    // PersistorGaOuu te waits for state to be loaded before rendering
    return PersistorGate(
      persistor: persistor,
      builder: (context) => StoreProvider(
            store: store,
            child: MaterialApp(title: 'Redux Persist Demo', home: HomePage()),
          ),
    );
  }
}

// Counter example
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Redux Persist demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StoreConnector<AppState, String>(
              converter: (store) => store.state.counter.toString(),
              builder: (context, count) => Text(
                    '$count',
                    style: Theme.of(context).textTheme.display1,
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: StoreConnector<AppState, VoidCallback>(
        // Return a function to dispatch an increment action
        converter: (store) => () => store.dispatch(IncrementCounterAction()),
        builder: (_, increment) => FloatingActionButton(
              onPressed: increment,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
      ),
    );
  }
}
