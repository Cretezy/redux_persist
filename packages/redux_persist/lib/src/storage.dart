import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// Interface for storage engines
abstract class StorageEngine {
  /// Save state ([data] could be null)
  Future<void> save(Uint8List? data);

  /// Load state (can return null)
  Future<Uint8List?> load();
}

/// Storage engine to save to file.
class FileStorage implements StorageEngine {
  /// File to save to.
  final File file;

  FileStorage(this.file);

  @override
  Future<Uint8List?> load() async {
    if (await file.exists()) {
      return Uint8List.fromList(await file.readAsBytes());
    }

    return null;
  }

  @override
  Future<void> save(Uint8List? data) async {
    await file.writeAsBytes(data ?? Uint8List(0));
  }
}

/// Storage engine to save to memory.
/// Do not use in production, this doesn't persist to disk.
class MemoryStorage implements StorageEngine {
  /// Internal memory.
  Uint8List? _memory;

  MemoryStorage([Uint8List? memory]) : _memory = memory;

  @override
  Future<Uint8List?> load() async => _memory;

  @override
  Future<void> save(Uint8List? data) async => _memory = data;
}
