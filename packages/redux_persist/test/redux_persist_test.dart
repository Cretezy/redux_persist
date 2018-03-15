import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import "package:test/test.dart";

void main() {
  test("loads on start", () async {
    TestStorage storage = new TestStorage();

    Persistor persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
    );

    Store store = new Store<State>(
      reducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    persistor.start(store);

    await expect(storage.loadStream, emits(storage.disk));
  });

  test("saves on changes", () async {
    TestStorage storage = new TestStorage();

    Persistor persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
    );

    Store store = new Store<State>(
      reducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    store.dispatch(new SetCounterAction(5));

    await expect(storage.saveStream, emits(json.encode(store.state.toJson())));
  });

  test("dispatches actions on load(ed)", () async {
    TestStorage storage = new TestStorage();

    Persistor persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
    );

    StreamController<String> actionsStreamController =
        new StreamController<String>.broadcast();

    State testReducer(State state, dynamic action) {
      if (action is LoadAction<State>) {
        actionsStreamController.add("load");
      } else if (action is LoadedAction<State>) {
        actionsStreamController.add("loaded");
      }
      return state;
    }

    Store store = new Store<State>(
      testReducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    await Future.wait<void>([
      expectLater(
        actionsStreamController.stream,
        emitsInOrder(["load", "loaded"]),
      ),
      persistor.start(store)
    ]);
  });
}

class TestStorage extends StorageEngine {
  String disk;

  final StreamController<String> _saveStreamControllers =
      new StreamController<String>.broadcast();

  final StreamController<String> _loadStreamControllers =
      new StreamController<String>.broadcast();

  TestStorage([this.disk = '{ "counter": 0 }']);

  Stream<String> get saveStream => _saveStreamControllers.stream;

  Stream<String> get loadStream => _loadStreamControllers.stream;

  Future<void> save(String json) async {
    _saveStreamControllers.add(json);
    disk = json;
  }

  Future<String> load() async {
    _loadStreamControllers.add(disk);
    return disk;
  }
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

  Map<String, int> toJson() => {'counter': counter};
}

class SetCounterAction {
  final int counter;

  SetCounterAction(this.counter);
}

State reducer(State state, Object action) {
  // Load to state
  if (action is LoadedAction<State>) {
    return action.state ?? state;
  }

  if (action is SetCounterAction) {
    return state.copyWith(counter: action.counter);
  }

  return state;
}
