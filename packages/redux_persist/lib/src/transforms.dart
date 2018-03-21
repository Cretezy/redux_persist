/// Transforms state (immutable).
typedef T Transformer<T>(T state);

/// Holds onSave and onLoad transformations.
class Transforms<T> {
  /// Transformation performed before saving.
  final List<Transformer<T>> onSave;

  /// Transformation performed after loading.
  final List<Transformer<T>> onLoad;

  Transforms({this.onSave, this.onLoad});
}

/// Transforms JSON state (immutable).
typedef String RawTransformer(String json);

/// Holds onSave and onLoad raw transformations.
class RawTransforms {
  /// Raw transformation performed before saving.
  final List<RawTransformer> onSave;

  /// Raw transformation performed after loading.
  final List<RawTransformer> onLoad;

  RawTransforms({this.onSave, this.onLoad});
}

/// State migrations (immutable).
typedef dynamic Migration(dynamic state);
