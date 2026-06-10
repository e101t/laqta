class CachePolicy {
  const CachePolicy({required this.pathPattern, required this.ttl});

  final String pathPattern;
  final Duration ttl;

  bool matches(Uri uri) {
    final path = uri.path.replaceFirst('/api/v1', '');
    if (pathPattern.contains('{username}')) {
      final prefix = pathPattern.split('{username}').first;
      return path.startsWith(prefix);
    }
    return path == pathPattern || path.startsWith('$pathPattern/');
  }

  static const policies = <CachePolicy>[
    CachePolicy(pathPattern: '/users/me', ttl: Duration(minutes: 5)),
    CachePolicy(pathPattern: '/users/{username}', ttl: Duration(minutes: 10)),
    CachePolicy(pathPattern: '/timeline/home', ttl: Duration(minutes: 2)),
    CachePolicy(pathPattern: '/timeline/explores', ttl: Duration(minutes: 5)),
    CachePolicy(pathPattern: '/category', ttl: Duration(hours: 24)),
    CachePolicy(pathPattern: '/app/version', ttl: Duration(hours: 1)),
    CachePolicy(pathPattern: '/config/features', ttl: Duration(hours: 1)),
  ];

  static CachePolicy? forUri(Uri uri) {
    for (final policy in policies) {
      if (policy.matches(uri)) {
        return policy;
      }
    }
    return null;
  }
}
