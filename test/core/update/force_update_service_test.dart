import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:laqta/core/update/force_update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('force update is required below minimum version', () async {
    final service = ForceUpdateService.debug(
      currentVersionCodeOverride: 1,
      client: MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(
            '{"minimum_version_code":5,"latest_version_code":8,"force_update":false,"update_url":"https://play.google.com/store/apps/details?id=com.laqta.laqta","release_notes_ar":"تحديث","release_notes_en":"Update"}',
          ),
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final result = await service.checkForUpdate();

    expect(result, isNotNull);
    expect(result!.isForceRequired, isTrue);
  });
}
