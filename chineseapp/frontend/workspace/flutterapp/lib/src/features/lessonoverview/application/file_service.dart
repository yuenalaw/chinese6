import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileService {
  FileService(this.ref);
  final Ref ref;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename');
  }

  Future<String> readFile(String filename) async {
    try {
      final file = await _localFile(filename);
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '';
    }
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService(ref);
});