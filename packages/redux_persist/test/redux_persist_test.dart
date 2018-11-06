import 'package:redux_persist/redux_persist.dart';
import 'package:test/test.dart';

void main() {
  test("loads", () async {
    final serializer = StringSerializer();
    final initialState = "hello";
    final storage = MemoryStorage(serializer.encode(initialState));

    final persistor = Persistor<String>(
      storage: storage,
      serializer: serializer,
    );

    final loadedState = await persistor.load();

    expect(loadedState, equals(initialState));
  });

  test("saves", () async {
    final serializer = StringSerializer();
    final storage = MemoryStorage();

    final persistor = Persistor<String>(
      storage: storage,
      serializer: serializer,
    );

    final state = "hello";

    await persistor.save(state);

    expect(serializer.decode(await storage.load()), equals(state));
  });

  test("json serializes empty state", () async {
    final serializer = JsonSerializer<Object>((dynamic data) => data);

    expect(serializer.decode(null), equals(null));
  });
}
