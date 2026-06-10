import 'dart:convert';
import 'dart:typed_data';

class SecureString {
  SecureString(String value) : _bytes = Uint8List.fromList(utf8.encode(value));

  Uint8List _bytes;
  bool _disposed = false;

  String exposeForImmediateUse() {
    if (_disposed) {
      throw StateError('SecureString has been disposed.');
    }
    return utf8.decode(_bytes);
  }

  void dispose() {
    for (var i = 0; i < _bytes.length; i++) {
      _bytes[i] = 0;
    }
    _bytes = Uint8List(0);
    _disposed = true;
  }
}
