import 'dart:async';
import 'dart:io';

/// Interface for storage engines
abstract class StorageEngine {
  /// Save state to disk as string
  external Future<void> save(String json);

  /// Load state from disk as string
  external Future<String> load();
}

/// Storage engine to save to file.
class FileStorage implements StorageEngine {
  /// Path to save to.
  final String path;

  FileStorage(this.path);

  @override
  load() async {
    final file = await _getFile();

    if (await file.exists()) {
      return await file.readAsString();
    }

    return null;
  }

  @override
  save(String json) async {
    final file = await _getFile();

    await file.writeAsString(json);
  }

  Future<File> _getFile() async => new File(path);
}

/// Storage engine to save to memory.
/// Do not use in production, this doesn't persist to disk.
class MemoryStorage implements StorageEngine {
  /// Internal memory.
  String _memory;

  MemoryStorage(String memory) : _memory = memory;

  @override
  load() async => _memory;

  @override
  save(String json) async => _memory = json;
}
