import 'dart:async';

import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:test/test.dart';

void main() {
  test("loads on start", () async {
    TestStorage storage = new TestStorage();

    final persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
    );

    final store = new Store<State>(
      reducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    persistor.start(store);

    expectLater(storage.loadStream, emits(storage.disk));
  });

  // Broken
  // test("saves on changes", () async {
  //   TestStorage storage = new TestStorage();
  //
  //   final persistor = new Persistor<State>(
  //     storage: storage,
  //     decoder: State.fromJson,
  //   );
  //
  //   final store = new Store<State>(
  //     reducer,
  //     initialState: new State(),
  //     middleware: [persistor.createMiddleware()],
  //   );
  //
  //   await persistor.start(store);
  //
  //   store.dispatch(new SetCounterAction(5));
  //
  //   await expectLater(
  //     storage.saveStream, // Skip the start
  //     emits((String expected) =>
  //         expected == json.encode({"version": -1, "state": store.state})),
  //   );
  // });

  test("dispatches actions on load(ed)", () async {
    TestStorage storage = new TestStorage();

    final persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
    );

    StreamController<String> actionsStreamController =
        new StreamController<String>.broadcast();

    State testReducer(State state, Object action) {
      if (action is PersistLoadingAction) {
        actionsStreamController.add("load");
      } else if (action is PersistLoadedAction<State>) {
        actionsStreamController.add("loaded");
      }
      return state;
    }

    final store = new Store<State>(
      testReducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    expectLater(
      actionsStreamController.stream,
      emitsInOrder(["load", "loaded"].toList()),
    );

    persistor.start(store);
  });

  test("migrate to new version", () async {
    TestStorage storage = new TestStorage();

    final persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
      version: 1,
      migrations: {
        0: (dynamic state) => {"counter": 5},
        1: (dynamic state) => {"counter": (state["counter"] as int) + 1}
      },
    );

    final store = new Store<State>(
      reducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    final state = await persistor.start(store);

    expect(state.counter, 6);
  });

  test("loads and migrate to old version", () async {
    // Make only the version 1 migration happen
    TestStorage storage =
        new TestStorage('{ "version": 0, "state": { "counter": 0 } }');

    final persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
      version: 1,
      migrations: {
        0: (dynamic state) => {"counter": 5},
        1: (dynamic state) => {"counter": (state["counter"] as int) + 1}
      },
    );

    final store = new Store<State>(
      reducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    final state = await persistor.start(store);

    expect(state.counter, 1);
  });

  test("throws on bad json", () async {
    // Load bad JSON
    TestStorage storage = new TestStorage('this is not json');

    final persistor = new Persistor<State>(
      storage: storage,
      decoder: State.fromJson,
    );
    final store = new Store<State>(
      reducer,
      initialState: new State(),
      middleware: [persistor.createMiddleware()],
    );

    expect(persistor.start(store),
        throwsA((dynamic error) => error is SerializationException));
  });
}

class TestStorage extends StorageEngine {
  String disk;

  final StreamController<String> _saveStreamControllers =
      new StreamController<String>.broadcast();

  final StreamController<String> _loadStreamControllers =
      new StreamController<String>.broadcast();

  TestStorage([this.disk = '{ "version": -1, "state": { "counter": 0 } }']);

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

  dynamic toJson() => {'counter': counter};
}

class SetCounterAction {
  final int counter;

  SetCounterAction(this.counter);
}

State reducer(State state, Object action) {
  // Load to state
  if (action is PersistLoadedAction<State>) {
    return action.state ?? state;
  }

  if (action is SetCounterAction) {
    return state.copyWith(counter: action.counter);
  }

  return state;
}
