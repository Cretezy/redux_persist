import 'dart:convert';
import 'dart:typed_data';

/// Serializer interface for turning state ([T]) into [Uint8List], and back
abstract class StateSerializer<T> {
  Uint8List encode(T state);

  T decode(Uint8List data);
}

class JsonSerializer<T> implements StateSerializer<T> {
  /// Turns the dynamic [json] (can be null) to [T]
  final T Function(dynamic json) decoder;

  JsonSerializer(this.decoder);

  @override
  T decode(Uint8List data) {
    return decoder(data != null ? json.decode(uint8ListToString(data)) : null);
  }

  @override
  Uint8List encode(T state) {
    if (state == null) {
      return null;
    }

    return stringToUint8List(json.encode(state));
  }
}

/// Serializer for a [String] state
class StringSerializer implements StateSerializer<String> {
  @override
  String decode(Uint8List data) {
    return uint8ListToString(data);
  }

  @override
  Uint8List encode(String state) {
    return stringToUint8List(state);
  }
}

/// Serializer for a [Uint8List] state, basically pass-through
class RawSerializer implements StateSerializer<Uint8List> {
  @override
  Uint8List decode(Uint8List data) => data;

  @override
  Uint8List encode(Uint8List state) => state;
}

// String helpers

Uint8List stringToUint8List(String data) {
  if (data == null) {
    return null;
  }

  return Uint8List.fromList(utf8.encode(data));
}

String uint8ListToString(Uint8List data) {
  if (data == null) {
    return null;
  }

  return utf8.decode(data);
}
