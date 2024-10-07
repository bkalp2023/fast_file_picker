import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:ios_document_picker/ios_document_picker.dart';
import 'package:ios_document_picker/ios_document_picker_platform_interface.dart';
import 'package:macos_file_picker/macos_file_picker.dart';
import 'package:macos_file_picker/macos_file_picker_platform_interface.dart';
import 'package:saf_util/saf_util.dart';

/// Represents a picker result that could be either a file path or a URI.
class FcFilePickerXResult {
  final String? path;
  final String? uri;

  FcFilePickerXResult._(this.path, this.uri);

  static FcFilePickerXResult? create({String? path, String? uri}) {
    if (path != null || uri != null) {
      return FcFilePickerXResult._(path, uri);
    }
    return null;
  }

  @override
  String toString() {
    return path ?? uri ?? '<null>';
  }
}

final SafUtil _safUtil = SafUtil();

/// A utility class for picking files.
class FcFilePickerUtil {
  /// Picks a file and return a
  /// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
  /// If the user cancels the picker, it returns `null`.
  static Future<XFile?> pickFile() async {
    final res = await pickFilesCore();
    if (res == null) {
      return null;
    }
    return res.first;
  }

  /// Picks multiple files and return a list of
  /// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
  /// If the user cancels the picker, it returns `null`.
  static Future<List<XFile>?> pickMultipleFiles() async {
    return pickFilesCore(allowsMultiple: true);
  }

  /// Picks a folder and return a [FcFilePickerXResult].
  /// If the user cancels the picker, it returns `null`.
  ///
  /// [writePermission] is only applicable on Android.
  static Future<FcFilePickerXResult?> pickFolder(
      {required bool writePermission}) async {
    if (Platform.isAndroid) {
      return FcFilePickerXResult.create(
          uri: await _safUtil.openDirectory(writePermission: writePermission));
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
        uri: first.url,
      );
    }
    if (Platform.isMacOS) {
      final macosPicker = MacosFilePicker();
      final res = await macosPicker.pick(MacosFilePickerMode.folder);
      if (res == null) {
        return null;
      }
      return FcFilePickerXResult.create(
          path: res.first.path, uri: res.first.url);
    }
    final folderPath = await getDirectoryPath();
    return FcFilePickerXResult.create(path: folderPath);
  }

  /// Picks a save file location and return a [String] path.
  /// You can optionally specify a default file name via [defaultName].
  /// If the user cancels the picker, it returns `null`.
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
