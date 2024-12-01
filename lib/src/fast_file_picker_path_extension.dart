import 'dart:io';

import 'package:accessing_security_scoped_resource/accessing_security_scoped_resource.dart';
import '../fast_file_picker.dart';

final _plugin = AccessingSecurityScopedResource();

extension FastFilePickerPathExtension on FastFilePickerPath {
  /// Starts accessing Apple security scoped resource.
  /// This has no effect on non-Apple platforms or if the path
  /// or URI is not set.
  ///
  /// Returns `null` if not applicable, `true` if access is granted,
  /// `false` if access is denied.
  Future<bool?> accessAppleScopedResource() async {
    if (uri == null || path == null) {
      return null;
    }
    if (!Platform.isIOS && !Platform.isMacOS) {
      return null;
    }
    final res = await _plugin.startAccessingSecurityScopedResourceWithURL(uri!);
    return res;
  }

  /// Stops accessing Apple security scoped resource.
  /// This has no effect on non-Apple platforms or if the path
  /// or URI is not set.
  ///
  /// [hasAccess] is the result of [accessAppleScopedResource].
  Future<void> releaseAppleScopedResource(bool? hasAccess) async {
    if (hasAccess != true) {
      return;
    }
    if (uri == null || path == null) {
      return;
    }
    if (!Platform.isIOS && !Platform.isMacOS) {
      return;
    }
    await _plugin.stopAccessingSecurityScopedResourceWithURL(uri!);
  }

  /// Calls [accessAppleScopedResource] and [releaseAppleScopedResource] when
  /// [action] is done or fails.
  /// This has no effect on non-Apple platforms or if the path
  /// or URI is not set.
  Future<bool?> useAppleScopedResource(
      Future<void> Function(FastFilePickerPath pickerPath) action) async {
    if (uri == null || path == null) {
      return null;
    }
    if (!Platform.isIOS && !Platform.isMacOS) {
      return null;
    }
    bool hasAccess = false;
    try {
      hasAccess =
          await _plugin.startAccessingSecurityScopedResourceWithURL(uri!);
      if (hasAccess) {
        await action(this);
      }
    } finally {
      if (hasAccess) {
        await _plugin.stopAccessingSecurityScopedResourceWithURL(uri!);
      }
    }
    return hasAccess;
  }
}
