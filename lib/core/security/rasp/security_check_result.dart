enum SecuritySeverity { info, warning, critical }

class SecuritySignal {
  const SecuritySignal({
    required this.name,
    required this.detected,
    this.vectorCount = 0,
    this.vectors = const <String>[],
    this.details = const <String, Object?>{},
    this.severity = SecuritySeverity.info,
  });

  final String name;
  final bool detected;
  final int vectorCount;
  final List<String> vectors;
  final Map<String, Object?> details;
  final SecuritySeverity severity;

  static const clean = SecuritySignal(name: 'clean', detected: false);

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'detected': detected,
      'vector_count': vectorCount,
      'vectors': vectors,
      'details': details,
      'severity': severity.name,
    };
  }
}
