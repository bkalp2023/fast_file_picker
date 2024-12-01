Deprecated: Moved to [fast_file_picker](https://pub.dev/packages/fast_file_picker).

# fc_file_picker_util

[![pub package](https://img.shields.io/pub/v/fc_file_picker_util.svg)](https://pub.dev/packages/fc_file_picker_util)

|                  | Windows          | macOS                  | iOS                    | Android  |
| ---------------- | ---------------- | ---------------------- | ---------------------- | -------- |
| Pick files       | ✅ (Name / Path) | ✅ (Name / Path / URL) | ✅ (Name / Path / URL) | ✅ (Uri) |
| Pick a folder    | ✅ (Name / Path) | ✅ (Name / Path / URL) | ✅ (Name / Path / URL) | ✅ (Uri) |
| Pick a save path | ✅ (Name / Path) | ✅ (Name / Path / URL) | ❌                     | ❌       |

`fc_file_picker_util` is based on [file_selector](https://pub.dev/packages/file_selector) with the following differences:

- On iOS and macOS, it returns both URL and path for files and folders.
- On Android:
  - When picking files: instead of copying the file to a temporary location, it returns file SAF Uri directly.
  - When picking folder: it returns an SAF Uri.
  - To access the SAF Uri-based files or folders, use my other packages: [saf_stream](https://pub.dev/packages/saf_stream) and [saf_util](https://pub.dev/packages/saf_util).

## Usage

### macOS

You need to add the following key to entitlements in order for macOS app to be able to access file system:

```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
```

### `FcFilePickerPath`

Since `fc_file_picker_util` can return path or URI or both, the result is wrapped in `FcFilePickerPath`:

```dart
class FcFilePickerPath {
  final String name;
  final String? path;
  final String? uri;
}
```

### Pick a file or multiple files

```dart
/// Picks a file and return a [FcFilePickerPath].
final file = await FcFilePickerUtil.pickFile();

/// Picks multiple files and return a list of [FcFilePickerPath].
final files = await FcFilePickerUtil.pickMultipleFiles();
```

### Pick a folder

```dart
/// Picks a folder and return a [FcFilePickerPath].
///
/// [writePermission] is only applicable on Android.
final folder = await FcFilePickerUtil.pickFolder(writePermission: true);
```

### Pick a save path

> It's recommended to use mobile share menu to save files.

```dart
/// Picks a save file location and return a [String] path.
/// You can optionally specify a default file name via [defaultName].
final savePath = await FcFilePickerUtil.pickSaveFile();
```
