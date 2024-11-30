## 0.8.1

- Make `FcFilePickerPath` JSON serializable.

## 0.8.0

- Add `name` to `FcFilePickerPath`.

## 0.7.0

- Remove `file_picker` dependency.
- Set min iOS version to 14.0.
- **Breaking**: File picking functions return `FcFilePickerPath` instead of `FcFilePickerXResult`.
- Return both URL and path on iOS.

## 0.6.0

- Update to `saf_util` 0.2.0.

## 0.5.0

- Add required `writePermission` param to `pickFolder`

## 0.4.0

- Merge `iosUrl` and `androidUri` into `uri` in `FcFilePickerXResult`.
- Update gradle and kotlin versions.

## 0.3.0

- Update `mg_shared_storage` to 0.9.0

## 0.2.0

- Update `mg_shared_storage`.

## 0.1.0

- Allow `FcFilePickerXResult` to return different types of paths.

## 0.0.8

- Update `file_selector`.
- Don't reuse internal pickers.

## 0.0.3

- Set Flutter version to `3.7.0`.

## 0.0.2

- Switch to a forked version of `shared_storage`.

## 0.0.1

- Initial release.
