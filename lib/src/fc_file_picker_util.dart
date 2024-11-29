import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:ios_document_picker/ios_document_picker.dart';
import 'package:ios_document_picker/ios_document_picker_platform_interface.dart';
import 'package:macos_file_picker/macos_file_picker.dart';
import 'package:macos_file_picker/macos_file_picker_platform_interface.dart';
import 'package:saf_util/saf_util.dart';

/// Represents a picker path that could be either a file path or a URI.
class FcFilePickerPath {
  final String? path;
  final String? uri;

  FcFilePickerPath._(this.path, this.uri);

  static FcFilePickerPath? create({String? path, String? uri}) {
    if (path != null || uri != null) {
      return FcFilePickerPath._(path, uri);
    }
    return null;
  }

  static FcFilePickerPath fromUri(String uri) {
    return FcFilePickerPath._(null, uri);
  }

  static FcFilePickerPath fromPath(String path) {
    return FcFilePickerPath._(path, null);
  }

  @override
  String toString() {
    return 'FcFilePickerPath{path: $path, uri: $uri}';
  }
}

final SafUtil _safUtil = SafUtil();

/// A utility class for picking files.
class FcFilePickerUtil {
  /// Picks a file and return a
  /// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
  /// If the user cancels the picker, it returns `null`.
  static Future<FcFilePickerPath?> pickFile() async {
    final res = await pickFilesCore();
    return res?.first;
  }

  /// Picks multiple files and return a list of
  /// [XFile](https://pub.dev/documentation/cross_file/latest/cross_file/XFile-class.html).
  /// If the user cancels the picker, it returns `null`.
  static Future<List<FcFilePickerPath>?> pickMultipleFiles() async {
    return pickFilesCore(allowsMultiple: true);
  }

  /// Picks a folder and return a [FcFilePickerXResult].
  /// If the user cancels the picker, it returns `null`.
  ///
  /// [writePermission] is only applicable on Android.
  static Future<FcFilePickerPath?> pickFolder(
      {required bool writePermission}) async {
    if (Platform.isAndroid) {
      return FcFilePickerPath.create(
          uri: await _safUtil.openDirectory(writePermission: writePermission));
    }
    if (Platform.isIOS) {
      final iosPicker = IosDocumentPicker();
      final res = await iosPicker.pick(DocumentPickerType.directory);
      if (res == null) {
        return null;
      }
      final first = res.first;
      return FcFilePickerPath.create(
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
      return FcFilePickerPath.create(path: res.first.path, uri: res.first.url);
    }
    final folderPath = await getDirectoryPath();
    return FcFilePickerPath.create(path: folderPath);
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
  static Future<List<FcFilePickerPath>?> pickFilesCore(
      {bool? allowsMultiple}) async {
    if (Platform.isIOS) {
      final iosPicker = IosDocumentPicker();
      final files = await iosPicker.pick(DocumentPickerType.file,
          multiple: allowsMultiple ?? false);
      if (files == null) {
        return null;
      }
      final res = files
          .map((e) => FcFilePickerPath.create(path: e.path, uri: e.url))
          .nonNulls
          .toList();
      return res.isEmpty ? null : res;
    }
    // Use fast native macOS picker.
    if (Platform.isMacOS) {
      final macosPicker = MacosFilePicker();
      final files = await macosPicker.pick(MacosFilePickerMode.file,
          allowsMultiple: allowsMultiple ?? false);
      if (files == null) {
        return null;
      }
      final res = files
          .map((e) => FcFilePickerPath.create(path: e.path, uri: e.url))
          .nonNulls
          .toList();
      return res.isEmpty ? null : res;
    }
    if (Platform.isAndroid) {
      final files = await _safUtil.openFiles(multiple: allowsMultiple ?? false);
      if (files == null || files.isEmpty) {
        return null;
      }
      final res = files.map((f) => FcFilePickerPath.fromUri(f)).toList();
      return res.isEmpty ? null : res;
    }

    if (allowsMultiple == true) {
      final files = await openFiles();
      return files.isEmpty
          ? null
          : files.map((e) => FcFilePickerPath.fromPath(e.path)).toList();
    }

    final file = await openFile();
    return file == null ? null : [FcFilePickerPath.fromPath(file.path)];
  }
}
