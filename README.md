# fast_file_picker

[![pub package](https://img.shields.io/pub/v/fast_file_picker.svg)](https://pub.dev/packages/fast_file_picker)

`fast_file_picker` is a fast file picker for Flutter. To achieve the best performance, it returns OS file info directly and never performs any file copying or conversion. It supports picking files, folders, and save paths on all platforms. Partly based on [file_selector](https://pub.dev/packages/file_selector).

|                  | iOS                    | Android  | macOS                  | Windows / Linux  |
| ---------------- | ---------------------- | -------- | ---------------------- | ---------------- |
| Pick files       | ✅ (Name / Path / URL) | ✅ (Uri) | ✅ (Name / Path / URL) | ✅ (Name / Path) |
| Pick a folder    | ✅ (Name / Path / URL) | ✅ (Uri) | ✅ (Name / Path / URL) | ✅ (Name / Path) |
| Pick a save path | ⚠️                     | ⚠️       | ✅ (Name / Path / URL) | ✅ (Name / Path) |

- For each operation, please **follow the platform-specific notes below**.
- ⚠️: It's recommended to use mobile share menu on iOS and Android to save files.

## Usage

### Preqrequisites

On macOS, you need to add the following key to entitlements in order for macOS app to be able to access file system:

```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
```

### `FastFilePickerPath`

Since `fast_file_picker` can return path or URI or both, the result is wrapped in `FastFilePickerPath`:

```dart
class FastFilePickerPath {
  final String name;
  final String? path;
  final String? uri;
}
```

### Pick a file or multiple files

**Platform notes:**

- Windows / macOS / Linux: Use Dart IO to access the file.
- iOS: call `useAppleScopedResource` or `accessAppleScopedResource` to gain access first, then use Dart IO to access the file. See 'Apple scoped resource' section below for details.
- Android: use [saf_stream](https://pub.dev/packages/saf_stream) for file reading or [saf_util](https://pub.dev/packages/saf_util) for file info.

```dart
class FcFilePickerUtil {
  /// Picks a file and return a [FastFilePickerPath].
  /// If the user cancels the picker, it returns `null`.
  static Future<FastFilePickerPath?> pickFile();

  /// Picks multiple files and return a list of [FastFilePickerPath].
  /// If the user cancels the picker, it returns `null`.
  static Future<List<FastFilePickerPath>?> pickMultipleFiles();
}
```

Example:

```dart
final files = await FcFilePickerUtil.pickMultipleFiles();
if (files == null) {
  setState(() {
    _output = 'User canceled the picker';
  });
  return;
}

// Handle selected files.
for (final file in files) {
  if (Platform.isIOS) {
    // Handle iOS file.
    await file.useAppleScopedResource((hasAccess, file) async {
      // You can access the file only if [hasAccess] is true.
      if (!hasAccess) {
        return;
      }
      // Now you can read the file with Dart's IO.
      final bytes = await File(file.path!).readAsBytes();
    });
  } else if (file.uri != null && Platform.isAndroid) {
    // Handle Android file.
    // For example, use [saf_stream] package to read the file.
    final bytes = await _safStream.readFileBytes(file.uri!);
  } else if (file.path != null) {
    // Handle Windows / macOS / Linux file.
    final bytes = await File(file.path!).readAsBytes();
  }
}
```

### Pick a folder

**Platform notes:**

- Windows / macOS / Linux: Use Dart IO to access the folder.
- iOS: call `useAppleScopedResource` or `accessAppleScopedResource` to gain access first, then use Dart IO to access the folder. See 'Apple scoped resource' section below for details.
- Android: use [saf_stream](https://pub.dev/packages/saf_stream) for file IO inside the folder or [saf_util](https://pub.dev/packages/saf_util) for folder operations.

```dart
class FcFilePickerUtil {
  /// Picks a folder and return a [FastFilePickerPath].
  /// If the user cancels the picker, it returns `null`.
  ///
  /// [writePermission] is only applicable on Android.
  static Future<FastFilePickerPath?> pickFolder(
      {required bool writePermission});
}
```

Example:

```dart
// Handle selected folder.
final folder = await FcFilePickerUtil.pickFolder(
    writePermission: false);
if (folder == null) {
  setState(() {
    _output = 'Cancelled';
  });
  return;
}
if (Platform.isIOS) {
  // Handle iOS folder.

  // Use [useAppleScopedResource] to request access to the folder.
  await folder
      .useAppleScopedResource((hasAccess, folder) async {
    // You can access the folder only if [hasAccess] is true.
    if (!hasAccess) {
      setState(() {
        _output = 'No access to folder';
      });
      return;
    }
    final subFileNames =
        (await Directory(folder.path!).list().toList())
            .map((e) => e.path);

    setState(() {
      _output =
          'Folder: $folder\n\nSubfiles: $subFileNames';
    });
  });
} else if (Platform.isAndroid && folder.uri != null) {
  // Handle Android folder.

  // Use [saf_util] package to list files in the folder.
  // Or use [saf_stream] package to read the files.
  final subFileNames = (await _safUtil.list(folder.uri!))
      .map((e) => e.name);

  setState(() {
    _output =
        'Folder: $folder\n\nSubfiles: $subFileNames';
  });
} else if (folder.path != null) {
  // Handle Windows / macOS / Linux folder.
  final subFileNames =
      (await Directory(folder.path!).list().toList())
          .map((e) => e.path);

  setState(() {
    _output =
        'Folder: $folder\n\nSubfiles: $subFileNames';
  });
}
```

### Pick a save path

**Platform notes:**

- iOS / Android: Not supported. It's recommended to use mobile share menu to save files.
- Windows / macOS / Linux: Use Dart IO to handle the save path.

```dart
class FcFilePickerUtil {
  /// Picks a save file location and return a [String] path.
  /// You can optionally specify a default file name via [defaultName].
  /// If the user cancels the picker, it returns `null`.
  static Future<String?> pickSaveFile({String? defaultName});
}
```

Example:

```dart
final savePath = await FcFilePickerUtil.pickSaveFile();
if (savePath == null) {
  setState(() {
    _output = 'User canceled the picker';
  });
  return;
}
// Handle save path using Dart IO.
```
