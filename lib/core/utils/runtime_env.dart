import 'runtime_env_stub.dart'
    if (dart.library.io) 'runtime_env_io.dart';

/// Returns true when running under `flutter test`.
///
/// Flutter sets the `FLUTTER_TEST` environment variable for test runs.
bool isFlutterTestEnv() => runtimeEnvIsFlutterTest();

