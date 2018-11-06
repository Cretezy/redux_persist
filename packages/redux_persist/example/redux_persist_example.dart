import 'dart:io';

import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';

void main() async {
  final persistor = Persistor<State>(
    storage: FileStorage(File("state.json")),
    serializer: JsonSerializer<State>(State.fromJson),
  );

  // Load initial state
  final initialState = await persistor.load();

  final store = Store<State>(
    reducer,
    initialState: initialState ?? State(),
    middleware: [persistor.createMiddleware()],
  );

  // ...
}

class State {
  final int counter;

  State({this.counter = 0});

  State copyWith({int counter}) => State(counter: counter ?? this.counter);

  static State fromJson(dynamic json) => State(counter: json["counter"] as int);

  dynamic toJson() => {'counter': counter};
}

class IncrementCounterAction {}

State reducer(State state, Object action) {
  if (action is IncrementCounterAction) {
    // Increment
    return state.copyWith(counter: state.counter + 1);
  }

  return state;
}
