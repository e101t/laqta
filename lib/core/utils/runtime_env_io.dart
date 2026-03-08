import 'dart:io' show Platform;

bool runtimeEnvIsFlutterTest() => Platform.environment.containsKey('FLUTTER_TEST');

