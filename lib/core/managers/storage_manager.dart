// Dart imports:
import 'dart:io';

// Package imports:
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:notredame/locator.dart';

// Project imports:

class StorageManager {
  final String tag = "StorageManager";

  final Logger _logger = locator<Logger>();

  /// Get the path of the application's documents directory. The path is platform specific.
  /// This directory will be deleted when the application is uninstalled.
  Future<String> getAppDocumentsDirectoryPath() async {
    return Platform.isAndroid
        ? getExternalStorageDirectory()
            .then((directory) => directory!.path) //FOR ANDROID
        : getApplicationSupportDirectory()
            .then((directory) => directory.path); //FOR iOS
  }

  /// Get the local file with the [filename].
  Future<File> getLocalFile(String filename) async {
    return File('${await getAppDocumentsDirectoryPath()}/$filename');
  }

  /// Returns the contents of the file with [filename] as a string.
  Future<String> readFile(String filename) async {
    final file = await getLocalFile(filename);

    final contents = await file.readAsString();
    _logger.d("$tag - readFile(): $filename");

    return contents;
  }

  /// Write the [contents] to the file with the [filename].
  /// Returns the file that was written to.
  Future<File> writeToFile(String filename, String contents,
      [FileMode fileMode = FileMode.write]) async {
    final file = await getLocalFile(filename);

    final result = await file.writeAsString(contents, mode: fileMode);
    _logger.d("$tag - writeToFile: Written to file $filename - ${result.path}");

    return result;
  }

  /// Check if the file exists in the storage.
  Future<bool> fileExists(String fileName) async {
    final File file = await getLocalFile(fileName);
    return file.exists();
  }
}
