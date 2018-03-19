import 'dart:async';
import 'dart:io';

// Interface for storage engines
abstract class StorageEngine {
  external Future<void> save(String json);

  external Future<String> load();
}

/// Storage engine to save to file
class FileStorage implements StorageEngine {
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

  Future<File> _getFile() async {
    return new File(path);
  }
}
