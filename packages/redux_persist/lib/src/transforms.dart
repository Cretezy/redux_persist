import 'dart:typed_data';

/// Transforms state to new state.
/// Do not mutate original state.
/// Could be ran with null state.
typedef T Transformer<T>(T state);

/// Holds onSave and onLoad transformations.
class Transforms<T> {
  /// Transformation performed before saving.
  final List<Transformer<T>> onSave;

  /// Transformation performed after loading.
  final List<Transformer<T>> onLoad;

  Transforms({this.onSave, this.onLoad});
}

/// Transforms byte state data (immutable).
/// Do not mutate original data.
/// Could be ran with null or empty data.
typedef Uint8List RawTransformer(Uint8List data);

/// Holds onSave and onLoad raw transformations.
class RawTransforms {
  /// Raw transformation performed before saving.
  final List<RawTransformer> onSave;

  /// Raw transformation performed after loading.
  final List<RawTransformer> onLoad;

  RawTransforms({this.onSave, this.onLoad});
}
