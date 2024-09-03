import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:ios_document_picker/ios_document_picker.dart';
import 'package:ios_document_picker/ios_document_picker_platform_interface.dart';
import 'package:macos_file_picker/macos_file_picker.dart';
import 'package:macos_file_picker/macos_file_picker_platform_interface.dart';
import 'package:mg_shared_storage/shared_storage.dart' as saf;

/// Represents a picker result that could be either a file path or a URI.
class FcFilePickerXResult {
  final String? path;
  final String? iosUrl;
  final Uri? androidUri;

  FcFilePickerXResult._(this.path, this.androidUri, this.iosUrl);

  static FcFilePickerXResult? create(
      {String? path, Uri? androidUri, String? iosUrl}) {
    if (path != null || androidUri != null || iosUrl != null) {
      return FcFilePickerXResult._(path, androidUri, iosUrl);
    }
    return null;
  }

  @override
  String toString() {
    return path ?? androidUri?.toString() ?? iosUrl ?? '<null>';
  }
}

/// A utility class for picking files.
class FcFilePickerUtil {
  /// Picks a file and return a
  /// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
  static Future<XFile?> pickFile() async {
    final res = await pickFilesCore();
    if (res == null) {
      return null;
    }
    return res.first;
  }

  /// Picks multiple files and return a list of
  /// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
  static Future<List<XFile>?> pickMultipleFiles() async {
    return pickFilesCore(allowsMultiple: true);
  }

  /// Picks a folder and return a [FilePickerXResult].
  static Future<FcFilePickerXResult?> pickFolder() async {
    if (Platform.isAndroid) {
      return FcFilePickerXResult.create(
          androidUri: await saf.openDocumentTree());
    }
    if (Platform.isIOS) {
      final iosPicker = IosDocumentPicker();
      final res = await iosPicker.pick(DocumentPickerType.directory);
      if (res == null) {
        return null;
      }
      final first = res.first;
      return FcFilePickerXResult.create(
        path: first.path,
        iosUrl: first.url,
      );
    }
    if (Platform.isMacOS) {
      final macosPicker = MacosFilePicker();
      final res = await macosPicker.pick(MacosFilePickerMode.folder);
      if (res == null) {
        return null;
      }
      return FcFilePickerXResult.create(
          path: res.first.path, iosUrl: res.first.url);
    }
    final folderPath = await getDirectoryPath();
    return FcFilePickerXResult.create(path: folderPath);
  }

  /// Picks a save file location and return a [String] path.
  /// You can optionally specify a default file name.
  static Future<String?> pickSaveFile({String? defaultName}) async {
    if (Platform.isMacOS) {
      final macosPicker = MacosFilePicker();
      final res = await macosPicker.pick(MacosFilePickerMode.saveFile,
          defaultName: defaultName);
      if (res == null) {
        return null;
      }
      return res.first.path;
    }
    final res = await getSaveLocation(suggestedName: defaultName);
    return res?.path;
  }

  /// Called by [pickFile] and [pickMultipleFiles].
  static Future<List<XFile>?> pickFilesCore({bool? allowsMultiple}) async {
    // Use fast native macOS picker.
    if (Platform.isMacOS) {
      final macosPicker = MacosFilePicker();
      final res = await macosPicker.pick(MacosFilePickerMode.file,
          allowsMultiple: allowsMultiple ?? false);
      if (res == null) {
        return null;
      }
      return res.map((e) => XFile(e.path)).toList();
    }
    // file_selector Android implementation is slow,
    // which loads all bytes of the file into memory.
    if (Platform.isAndroid) {
      final res = await FilePicker.platform
          .pickFiles(allowMultiple: allowsMultiple ?? false);
      if (res == null) {
        return null;
      }
      final androidFiles = res.files
          .map((e) => e.path)
          .whereType<String>()
          .map((e) => XFile(e))
          .toList();
      if (androidFiles.isEmpty) {
        return null;
      }
      return androidFiles;
    }

    if (allowsMultiple == true) {
      final files = await openFiles();
      return files.isEmpty ? null : files;
    }

    final file = await openFile();
    return file == null ? null : [file];
  }
}
