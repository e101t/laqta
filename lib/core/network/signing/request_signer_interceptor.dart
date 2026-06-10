import 'package:http/http.dart' as http;
import 'package:laqta/core/network/signing/request_signer.dart';

class RequestSignerInterceptor {
  RequestSignerInterceptor({RequestSigner? signer})
    : _signer = signer ?? RequestSigner();

  final RequestSigner _signer;

  Future<void> apply({
    required http.BaseRequest request,
    String? body,
    String? accessToken,
    bool sensitive = false,
  }) async {
    request.headers.addAll(
      await _signer.buildHeaders(
        method: request.method,
        uri: request.url,
        body: body,
        accessToken: accessToken,
        sensitive: sensitive,
      ),
    );
  }
}
