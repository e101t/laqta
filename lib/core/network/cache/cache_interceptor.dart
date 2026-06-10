import 'package:http/http.dart' as http;
import 'package:laqta/core/network/cache/cache_policy.dart';
import 'package:laqta/core/network/cache/response_cache.dart';

class CacheInterceptor {
  CacheInterceptor({ResponseCache? cache}) : _cache = cache ?? ResponseCache();

  final ResponseCache _cache;

  String cacheKey(String method, Uri uri) {
    final query = uri.queryParameters.keys.toList()..sort();
    final sortedQuery = query
        .map((key) => '$key=${uri.queryParameters[key]}')
        .join('&');
    return '${method.toUpperCase()} ${uri.path}?$sortedQuery';
  }

  Future<http.Response?> readFresh(String method, Uri uri) async {
    if (method.toUpperCase() != 'GET') return null;
    final policy = CachePolicy.forUri(uri);
    if (policy == null) return null;
    final cached = await _cache.get(cacheKey(method, uri));
    if (cached == null || !cached.isFresh) return null;
    return http.Response(
      cached.body,
      cached.statusCode,
      headers: cached.headers,
    );
  }

  Future<void> write(String method, Uri uri, http.Response response) async {
    if (method.toUpperCase() != 'GET') return;
    if (response.statusCode < 200 || response.statusCode >= 300) return;
    final policy = CachePolicy.forUri(uri);
    if (policy == null) return;
    final cacheControl = response.headers['cache-control'];
    final ttl = _ttlFromCacheControl(cacheControl) ?? policy.ttl;
    await _cache.put(
      cacheKey(method, uri),
      CachedApiResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        cachedAtMs: DateTime.now().millisecondsSinceEpoch,
        ttlMs: ttl.inMilliseconds,
      ),
    );
  }

  Future<void> clearUserCache() => _cache.clearUserCache();

  Duration? _ttlFromCacheControl(String? value) {
    if (value == null || value.isEmpty) return null;
    final match = RegExp(r'max-age=(\d+)').firstMatch(value);
    if (match == null) return null;
    final seconds = int.tryParse(match.group(1) ?? '');
    return seconds == null ? null : Duration(seconds: seconds);
  }
}
