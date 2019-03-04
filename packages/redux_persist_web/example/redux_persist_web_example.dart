import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_web/redux_persist_web.dart';

void main() async {
  // Create Persistor
  final persistor = Persistor<AppState>(
    storage: WebStorage(),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  // Load initial state
  final initialState = await persistor.load();

  final store = Store<AppState>(
    reducer,
    initialState: initialState ?? AppState(),
    middleware: [persistor.createMiddleware()],
  );

  // ...
}

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
  if (action is IncrementCounterAction) {
    // Increment
    return state.copyWith(counter: state.counter + 1);
  }

  return state;
}
