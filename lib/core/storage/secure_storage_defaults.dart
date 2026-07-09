import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared hardened secure-storage instance.
///
/// Android (plugin v10+) already uses AES keys held in the hardware-backed
/// KeyStore by default. On iOS/macOS the default keychain accessibility is
/// `unlocked`; we pin it to `first_unlock_this_device` so secrets are never
/// restored onto a different device from a backup and stay readable for
/// background refresh after the first unlock.
const FlutterSecureStorage hardenedSecureStorage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
  mOptions: MacOsOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);
