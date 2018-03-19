class InvalidVersionException implements Exception {
  final String msg;

  const InvalidVersionException(this.msg);

  String toString() => 'VersionException: $msg';
}

class TransformationException implements Exception {
  final String msg;

  const TransformationException(this.msg);

  String toString() => 'TransformationException: $msg';
}

class StorageException implements Exception {
  final String msg;

  const StorageException(this.msg);

  String toString() => 'StorageException: $msg';
}

class SerializationException implements Exception {
  final String msg;

  const SerializationException(this.msg);

  String toString() => 'SerializationException: $msg';
}
