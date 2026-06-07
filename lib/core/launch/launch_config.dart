class LaunchConfig {
  const LaunchConfig({
    required this.softLaunchEnabled,
    required this.allowedCities,
    required this.maxPhotographers,
    required this.maxUsers,
    required this.waitlistEnabled,
    required this.currentPhotographers,
    required this.currentUsers,
    required this.capacityReached,
  });

  factory LaunchConfig.fromJson(Map<String, dynamic> json) {
    return LaunchConfig(
      softLaunchEnabled: json['softLaunchEnabled'] as bool? ?? false,
      allowedCities: (json['allowedCities'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      maxPhotographers: json['maxPhotographers'] as int? ?? 20,
      maxUsers: json['maxUsers'] as int? ?? 50,
      waitlistEnabled: json['waitlistEnabled'] as bool? ?? true,
      currentPhotographers: json['currentPhotographers'] as int? ?? 0,
      currentUsers: json['currentUsers'] as int? ?? 0,
      capacityReached: json['capacityReached'] as bool? ?? false,
    );
  }

  final bool softLaunchEnabled;
  final List<String> allowedCities;
  final int maxPhotographers;
  final int maxUsers;
  final bool waitlistEnabled;
  final int currentPhotographers;
  final int currentUsers;
  final bool capacityReached;

  bool allowsCity(String city) {
    if (!softLaunchEnabled || allowedCities.isEmpty) {
      return true;
    }
    final normalized = city.trim().toLowerCase();
    return allowedCities.any(
      (allowed) => allowed.trim().toLowerCase() == normalized,
    );
  }
}

class WaitlistEntryInput {
  const WaitlistEntryInput({
    required this.name,
    required this.phone,
    required this.city,
    required this.roleInterest,
  });

  final String name;
  final String phone;
  final String city;
  final String roleInterest;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'phone': phone,
    'city': city,
    'roleInterest': roleInterest,
  };
}
