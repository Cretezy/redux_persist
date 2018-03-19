import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';

void main() async {
  final persistor = new Persistor<State>(
    storage: new FileStorage("state.json"),
    decoder: State.fromJson,
  );

  final store = new Store<State>(
    reducer,
    initialState: new State(),
    middleware: [persistor.createMiddleware()],
  );

  // Load initial state
  await persistor.start(store);

  // ...
}

class State {
  final int counter;

  State({this.counter = 0});

  State copyWith({int counter}) {
    return new State(counter: counter ?? this.counter);
  }

  static State fromJson(dynamic json) {
    return new State(counter: json["counter"] as int);
  }

  dynamic toJson() => {'counter': counter};
}

class IncrementCounterAction {}

State reducer(State state, Object action) {
  if (action is LoadedAction<State>) {
    // Load to state
    return action.state ?? state;
  } else if (action is IncrementCounterAction) {
    // Increment
    return state.copyWith(counter: state.counter + 1);
  }

  return state;
}
